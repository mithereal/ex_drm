(() => {
  class WebsocketHandler {
    setupSocket(url) {

      this.socket = new WebSocket(url)

      this.socket.addEventListener("message", (event) => {

        const res = JSON.parse(event.data)

        res.forEach(function (element) {
          let liTag = document.createElement("li")
          liTag.innerHTML = element.hash + " - " + element.meta.email + " - " + element.meta.name
          document.getElementById("licenses").append(liTag)

        });
      })

      this.socket.addEventListener("licenses", (event) => {
        const pTag = document.createElement("p")
        pTag.innerHTML = event.data

        document.getElementById("licenses").append(pTag)
      })

      this.socket.addEventListener("close", () => {
        this.setupSocket()
      })

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

    licenses() {
      event.preventDefault()

      const licenses = document.getElementById("licenses")

      while (licenses.hasChildNodes()) {
        licenses.removeChild(licenses.firstChild);
      }

      this.socket.send(
        JSON.stringify({
          data: { message: "list_licenses" },
        })
      )
    }
  }
  const url = "ws://localhost:4000/socket"

  const websocketClass = new WebsocketHandler()
  websocketClass.setupSocket(url)

  document.getElementById("button")
    .addEventListener("click", (event) => websocketClass.licenses())
})()