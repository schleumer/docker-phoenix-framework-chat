import {Socket, LongPoller} from "phoenix";
import $ from "jquery";

const me = window.CHANNEL_USER_ID;

class App {

  static init() {
    let socket = new Socket(`ws://${location.hostname}:8181/socket`, {
      logger: ((kind, msg, data) => {
        console.log(`${kind}: ${msg}`, data)
      })
    });

    socket.connect({user_id: me});
    var $status = $("#status");
    var $messages = $("#messages");
    var $input = $("#message-input");
    var $username = $("#username");

    socket.onOpen(ev => console.log("OPEN", ev));
    socket.onError(ev => console.log("ERROR", ev));
    socket.onClose(e => console.log("CLOSE", e));

    var chan = socket.channel("rooms:lobby", {});
    chan.join().receive("ignore", () => console.log("auth error"))
        .receive("ok", () => console.log("join ok"));

    chan.onError(e => console.log("something went wrong", e));
    chan.onClose(e => console.log("channel closed", e));

    $input.off("keypress").on("keypress", e => {
      if (e.keyCode == 13) {
        chan.push("new:msg", {user: $username.val(), body: $input.val()});
        $input.val("")
      }
    });

    chan.on("new:msg", msg => {
      $messages.append(this.messageTemplate(msg));
      scrollTo(0, document.body.scrollHeight)
    });

    chan.on(`new:msg:${me}`, msg => {
      $messages.append(this.privateMessageTemplate(msg));
      scrollTo(0, document.body.scrollHeight)
    });

    chan.on("user:entered", msg => {
      var username = this.sanitize(msg.user || "anonymous");
      $messages.append(`<br/><i>[${username} entered]</i>`)
    });

    $("#send-via-ajax").click(() => {
      $.post("/send-via-ajax");
    });
  }

  static sanitize(html) {
    return $("<div/>").text(html).html()
  }

  static privateMessageTemplate(msg) {
    let username = this.sanitize(msg.user || "anonymous");
    let body = this.sanitize(msg.body);

    return (`<p><a href='#'>[private][${username}]</a>&nbsp; ${body}</p>`)
  }

  static messageTemplate(msg) {
    let username = this.sanitize(msg.user || "anonymous");
    let body = this.sanitize(msg.body);

    return (`<p><a href='#'>[${username}]</a>&nbsp; ${body}</p>`)
  }

}

$(() => App.init())

export default App