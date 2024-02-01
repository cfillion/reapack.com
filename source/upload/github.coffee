import { encode as encodeArrayBuffer } from 'base64-arraybuffer'
import { UploadSource } from './file'
import { fileListToTree, normalizeLineBreaks } from './file-utils'

AUTH_SCOPE = 'public_repo workflow'
CLIENT_ID  = 'fdf42a6c354a7e6823f3'

export BASE_BRANCH = 'master'

fetchAPI = (method, endpoint, body, headers) ->
  response = await fetch "https://api.github.com#{endpoint}",
    method: method
    body: JSON.stringify body
    headers: {
      'Accept': 'application/vnd.github.v3+json'
      'Content-Type': 'application/json'
      'Authorization': "token #{getToken()}"
      headers...
    }

  json = await response.json()

  if response.ok
    json
  else
    throw json

GET  = (args...) -> fetchAPI 'GET',  args...
POST = (args...) -> fetchAPI 'POST', args...

wait = (time) -> new Promise (resolve) ->
  setTimeout resolve, time

autoRetry = (callback) ->
  attempts = 1

  while true
    try
      return data if data = await callback()
    catch e
      if attempts >= 5
        throw new Error "Operation failed after #{attempts} tries: #{e.message}."

    await wait 2000 * attempts++

getToken = ->
  sessionStorage.getItem 'github-token'

export openLoginPage = ->
  window.open "https://github.com/login/oauth/authorize?client_id=#{CLIENT_ID}&scope=#{AUTH_SCOPE}"

export getUser = -> GET '/user'

doLogin = ->
  try
    return await getUser() if getToken()
  catch
    logout()

  unless token = getToken()
    openLoginPage()
    await wait 250 until token = getToken()

  await getUser()

export login = ->
  if login.promise
    openLoginPage()
    return login.promise

  login.promise = doLogin()

  try
    user = await login.promise
    user
  finally
    login.promise = null

export logout = ->
  sessionStorage.removeItem 'github-token'

export getRepo = (name) ->
  GET "/repos/#{name}"

export createFork = (parentName) ->
  json = await POST "/repos/#{parentName}/forks"
  forkName = json.full_name

  try
    await autoRetry -> getRepo forkName
  catch
    throw new Error "Failed to create a fork of #{parentName} in your account."

  forkName

export syncFork = (repoName) ->
  POST "/repos/#{repoName}/merge-upstream",
    branch: BASE_BRANCH

export getHead = (repoName) ->
  GET "/repos/#{repoName}/commits/#{BASE_BRANCH}"

export createBlob = (repoName, file) ->
  params = if file.isBinary()
    encoding: 'base64'
    content: encodeArrayBuffer file.content
  else
    encoding: 'utf-8'
    content: file.header() + normalizeLineBreaks(file.content)

  path: file.storagePath()
  blob: await POST "/repos/#{repoName}/git/blobs", params

export removeFromTree = (repoName, baseTree, deletions) ->
  tree = (await GET "/repos/#{repoName}/git/trees/#{baseTree.sha}").tree

  for deletion in deletions
    objectIndex = tree.findIndex (object) => object.path == deletion.name
    continue if objectIndex == -1

    object = tree[objectIndex]

    if deletion.tree.length == 0
      tree.splice objectIndex, 1
    else if object.type == 'tree'
      subtree = await removeFromTree repoName, object, deletion.tree

      if subtree
        object.sha = subtree.sha
      else
        tree.splice objectIndex, 1

  if tree.length > 0
    POST "/repos/#{repoName}/git/trees", { tree }

export createTree = (repoName, blobs, baseTree) ->
  objects = blobs.map ({path, blob}) =>
    type: 'blob'
    path: path
    mode: '100644'
    sha: blob.sha

  POST "/repos/#{repoName}/git/trees",
    tree: objects,
    base_tree: baseTree.sha

export createCommit = (repoName, tree, parent, message) ->
  POST "/repos/#{repoName}/git/commits", {
    message,
    tree: tree.sha
    parents: [parent.sha]
  }

export createBranch = (repoName, name, commit) ->
  POST "/repos/#{repoName}/git/refs",
    ref: "refs/heads/#{name}"
    sha: commit.sha

export createPullRequest = (repoName, params) ->
  POST "/repos/#{repoName}/pulls", params

export openPullRequest = (pr) ->
  window.open pr.html_url

export getPullRequests = (repoName, author) ->
  issues = await GET "/repos/#{repoName}/issues?creator=#{encodeURIComponent author.login}"
  issue for issue in issues when issue.pull_request

export upload = (repoName, head, pkg) ->
  blobs = await Promise.all (
    for file in pkg.files when file.source == UploadSource
      createBlob repoName, file
  )

  deletedFiles = pkg.repoFiles.filter (repoFile) =>
    not blobs.find (blob) => blob.path == repoFile

  baseTree = if deletedFiles.length
    deletions = fileListToTree deletedFiles
    await removeFromTree repoName, head.commit.tree, deletions
  else
    head.commit.tree

  tree = await createTree repoName, blobs, baseTree
  commit = await createCommit repoName, tree, head, pkg.commitMessage()
