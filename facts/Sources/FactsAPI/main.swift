// Created by Leopold Lemmermann on 30.04.23.

import Vapor

let env = try Environment.detect()
let app = Application(env)
defer { app.shutdown() }

app.http.server.configuration.port = 4567

try app
  .configure(Facts())
  .run()
