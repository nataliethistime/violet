import violet/router
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist
import radiate

pub fn main() {
  // This sets the logger to print INFO level logs, and other sensible defaults
  // for a web application.
  wisp.configure_logger()

  // Here we generate a secret key, but in a real application you would want to
  // load this from somewhere so that it is not regenerated on every restart.
  let secret_key_base = wisp.random_string(64)

  // Start the Mist web server.
  let assert Ok(_) =
    wisp_mist.handler(router.handle_request, secret_key_base)
    |> mist.new
    |> mist.port(3000)
    |> mist.start_http

  // Listen for changes and reload when necessary
  // TODO: need to update this to only activate when developing locally
  let assert Ok(_) =
    radiate.new()
    |> radiate.add_dir(".")
    |> radiate.on_reload(fn (_state, path) {
      wisp.log_info("Change in " <> path <> ", reloading!")
    })
    |> radiate.start()

  // The web server runs in new Erlang process, so put this one to sleep while
  // it works concurrently.
  process.sleep_forever()
}
