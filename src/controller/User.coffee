http = require 'src/middleware/httpResponse'

isValidObjectId = require 'src/validator/type/ObjectId'

accountService = new (require 'src/service/Account')

UserMapper = require 'src/mapper/api/User'

check = require 'check-types'


class Controller

# ----------

  @index: (req, res, next) ->

    accountService.findAllUsers (err, users) ->
      return next( http.serverError(err, 1041) ) if err?

      res.data.users = users

      return next()
    return

# ----------

  @read: (req, res, next) ->

    unless isValidObjectId req.params.id
      return next( http.badRequest('Invalid user id', 1001) )

    accountService.findUserById req.params.id, (err, user) ->
      return next( http.serverError(err, 1003) ) if err?
      return next( http.notFound('user not found', 1002) ) unless user?

      res.data.user = user

      return next()
    return

# ----------

  @create: (req, res, next) ->

    return next( http.badRequest('Invalid user data', 1010) ) if check.isEmptyObject req.body

    try user = UserMapper.unmarshall req.body
    catch err then return next( http.badRequest(err, 1011) )

    accountService.createUser user, (err, user) ->
      return next( http.serverError(err, 1013) ) if err?

      res.status 201

      try res.data.user = UserMapper.marshall user
      catch err then return next( http.serverError(err, 1012) )

      return next()
    return


# ----------

  @edit: (req, res, next) ->

    unless isValidObjectId req.params.id
      return next( http.badRequest('Invalid user id', 1020) )

    if check.isEmptyObject req.body
      return next( http.badRequest('Invalid body', 1021) )

    try user = UserMapper.unmarshall req.body, user
    catch err then return next( http.badRequest(err, 1023) )

    accountService.findUserById req.params.id, (err, user) ->
      return next( http.serverError(err, 1003) ) if err?
      return next( http.notFound('user not found', 1022) ) unless user?

      accountService.updateUserById req.params.id, user, (err, user) ->
        return next( http.serverError(err, 1025) ) if err?

        try res.data.user = UserMapper.marshall user
        catch err then return next( http.serverError(err, 1024) )

        return next()
      return
    return

# ----------

  @remove: (req, res, next) ->

    unless isValidObjectId req.params.id
      return next( http.badRequest('Invalid user id', 1030) )

    accountService.removeUserById req.params.id, (err, user) ->
      return next( http.serverError(err, 1032) ) if err?
      return next( http.notFound('user not found', 1031) ) unless user?

      return next()
    return


module.exports = Controller
