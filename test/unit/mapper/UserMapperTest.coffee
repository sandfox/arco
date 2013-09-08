should   = require 'should'
ObjectID = require('mongodb').ObjectID
Hash     = require 'node-hash'

{userMapperMarshall, userMapperUnmarshall} = require 'src/mapper/User'

mockUsers = require('test/data/db/user').getData()

describe 'user mapper', ->

  describe 'marshall', ->

    describe 'failures', ->

      call() for call in allTypes.map (invalid) ->
        () ->
          it "should not marshall #{invalid}", ->
            (-> userMapperMarshall invalid).should.throw 'Invalid user'

    describe 'success', ->

      it 'should marshall the _id', ->
        data = userMapperMarshall userFactory 'fab', 'mos'
        should.exist data._id
        data._id.should.be.instanceof ObjectID

      it 'should marshall the first name', ->
        data = userMapperMarshall userFactory 'fab', 'mos'
        data.first_name.should.equal 'fab'

      it 'should marshall the last name', ->
        data = userMapperMarshall userFactory 'fab', 'mos'
        data.last_name.should.equal 'mos'

      it 'should marshall the email', ->
        data = userMapperMarshall userFactory().setEmail 'fabmos@gmail.com'
        data.email.should.equal 'fabmos@gmail.com'

      it 'should marshall the password', ->
        data = userMapperMarshall userFactory().setPassword 'mysupersecurepassword'
        data.password.should.equal 'mysupersecurepassword'

      it 'should marshall the gender', ->
        data = userMapperMarshall userFactory().setGender 'F'
        data.gender.should.equal 'F'

      it 'should marshall the birthdate', ->
        data = userMapperMarshall userFactory().setBirthdate new Date 1960, 0, 1
        data.birthdate.should.eql new Date 1960, 0, 1

      it 'should marshall the times', ->
        u = userFactory()
        u.times.set( 'created', new Date 2013, 0, 1)
        data = userMapperMarshall u
        data.times.created.should.eql new Date 2013, 0, 1

  describe 'unmarshall', ->

    describe 'failures', ->

      call() for call in allNotObjectTypes.map (invalid) ->
        () ->
          it "should not unmarshall #{invalid}", ->
            (-> userMapperUnmarshall invalid).should.throw 'Invalid data'

      call() for call in allNotUndefinedTypes.map (invalid) ->
        () ->
          it "should not unmarshall #{invalid}", ->
            (-> userMapperUnmarshall {}, invalid).should.throw 'Invalid user'

    describe 'success', ->

      it 'should unmarshall the _id', ->
        user = userMapperUnmarshall mockUsers.validUser1
        user.should.have.property 'id'
        user.id.should.equal mockUsers.validUser1._id.toHexString()

      it 'should unmarshall the first_name', ->
        user = userMapperUnmarshall mockUsers.validUser1
        user.should.have.property 'first_name'
        user.first_name.should.equal mockUsers.validUser1.first_name

      it 'should unmarshall the last_name', ->
        user = userMapperUnmarshall mockUsers.validUser1
        user.should.have.property 'last_name'
        user.last_name.should.equal mockUsers.validUser1.last_name

      it 'should unmarshall the email', ->
        user = userMapperUnmarshall mockUsers.validUser1
        user.should.have.property 'email'
        user.email.should.equal mockUsers.validUser1.email

      it 'should unmarshall the password', ->
        user = userMapperUnmarshall mockUsers.validUser1
        user.should.have.property 'password'
        user.password.should.equal mockUsers.validUser1.password

      it 'should unmarshall the birthdate', ->
        user = userMapperUnmarshall mockUsers.validUser1
        user.should.have.property 'birthdate'
        user.birthdate.should.be.instanceof Date
        user.birthdate.should.equal mockUsers.validUser1.birthdate

      it 'should unmarshall the times', ->
        user = userMapperUnmarshall mockUsers.validUser1
        user.should.have.property 'times'
        user.times.should.be.instanceof Hash
        user.times.getData().should.have.property 'created'
        user.times.get('created').should.be.instanceof Date
