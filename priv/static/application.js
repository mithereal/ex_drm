(() => {
  class WebsocketHandler {
    setupSocket() {
      this.socket = new WebSocket("ws://localhost:4000/socket")

      this.socket.addEventListener("message", (event) => {
        const pTag = document.createElement("p")
        pTag.innerHTML = event.data

        document.getElementById("main").append(pTag)
      })

      this.socket.addEventListener("users", (event) => {
        const pTag = document.createElement("p")
        pTag.innerHTML = event.data

        document.getElementById("users").append(pTag)
      })

      this.socket.addEventListener("close", () => {
        this.setupSocket()
      })

      // this.users()
    }

    submit(event) {
      event.preventDefault()
      const input = document.getElementById("message")
      const message = input.value

      this.socket.send(
        JSON.stringify({
          data: { message: message },
        })
      )
    }

    users() {
      event.preventDefault()
      this.socket.send(
        JSON.stringify({
          data: { message: "list_users" },
        })
      )
    }
  }

  const websocketClass = new WebsocketHandler()
  websocketClass.setupSocket()

  document.getElementById("button")
    .addEventListener("click", (event) => websocketClass.users())
})()