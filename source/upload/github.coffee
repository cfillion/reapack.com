import { encode as encodeArrayBuffer } from 'base64-arraybuffer'

AUTH_SCOPE = 'public_repo'
CLIENT_ID  = 'fdf42a6c354a7e6823f3'

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

getToken = -> sessionStorage.getItem 'github-token'

export openLoginPage = ->
  window.open "https://github.com/login/oauth/authorize?client_id=#{CLIENT_ID}&scope=#{AUTH_SCOPE}"

export getUser = -> GET '/user'

doLogin = ->
  try
    return await getUser()

  unless token = getToken()
    openLoginPage()
    await wait 250 until token = getToken()

  await getUser()

export login = ->
  if login.promise
    openLoginPage()
    return false

  login.promise = doLogin()
  user = await login.promise
  login.promise = null
  user

export logout = -> sessionStorage.removeItem 'github-token'

export getRepo = (name) -> GET "/repos/#{name}"

export fork = (parentName) ->
  json = await POST "/repos/#{parentName}/forks"
  forkName = json.full_name

  attempts = 1
  repo = null

  while true
    try
      repo = await getRepo forkName
      break if repo

    await wait 2000 * attempts++

    if attempts > 5
      throw new Error "Failed to create a fork of #{parentName} in your account."

  forkName

export getHead = (repoName) ->
  GET "/repos/#{repoName}/commits/master"

export branch = (repoName, name, commit) ->
  POST "/repos/#{repoName}/git/refs",
    ref: "refs/heads/#{name}"
    sha: commit.sha

export blob = (repoName, file) ->
  params = if file.isBinary()
    encoding: 'base64'
    content: encodeArrayBuffer file.content
  else
    encoding: 'utf-8'
    content: file.header() + file.content

  path: file.storagePath()
  blob: await POST "/repos/#{repoName}/git/blobs", params

export tree = (repoName, tree, baseTree) ->
  objects = for leaf in tree
    type: 'blob'
    path: leaf.path
    mode: '100644'
    sha: leaf.blob.sha

  POST "/repos/#{repoName}/git/trees", { tree: objects, base_tree: baseTree.sha }

export commit = (repoName, tree, parent, message) ->
  POST "/repos/#{repoName}/git/commits", {
    message,
    tree: tree.sha
    parents: [parent.sha]
  }

export pullRequest = (repoName, params) ->
  POST "/repos/#{repoName}/pulls", params

export openPullRequest = (pr) ->
  window.open pr.html_url

export getPullRequests = (repoName, author) ->
  issues = await GET "/repos/#{repoName}/issues?creator=#{encodeURIComponent author.login}"
  issue for issue in issues when issue.pull_request
