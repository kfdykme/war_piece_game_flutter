use ws::listen;

fn main() {
    println!("Hello, world!");
    if let Err(error) = listen("127.0.0.1:3012", |out| {
        move |msg| {
            println!("Server Receive message '{}'. ", msg);

            // out.send(msg)
            out.broadcast(msg)
        }
    }) {
        println!("create websocke fail {}", error)
    }
}
