import $ from "jquery"
const Device = require("@twilio/voice-sdk").Device

const Dialer = {
    number() { return this.el.dataset.number },
    token() { return this.el.dataset.token },
    buttons() { return this.el.dataset.buttons },
    mounted() {
        /* Set up Twilio device with token */
        const dialer = new Device(this.token())
        /* Let us know when the client is ready. */
        dialer.addListener("registered", function (device) {
            $("#dialer-log").html(`
            <div class="good-status-dot group">
                <i class="flex hero-phone hover:animate-pulse"></i>
                <span class="dialer-status-tooltip">Dialer Ready</span>
            </div>
            `);
        });
        /* Report any errors on the screen */
        dialer.addListener("error", function (error) {
            $("#dialer-log").html(`
            <div class="bad-status-dot group">
                <i class="flex hero-phone hover:animate-pulse"></i>
                <span class="dialer-status-tooltip">${error.message}</span>
            </div>
            `);
        });
        /* Handle when a call is incoming */
        dialer.addListener("incoming", function (call) {
            $("#dialer-log").text("Incoming connection from " + call.parameters.From);
            call.accept()
            this.buttons().split("").forEach((button) => {
                document.getElementById(`dial-${button}`).addEventListener("click", e => { call.sendDigits(button) })
            })
        })
        /* Adds click event listener to call button */
        document.getElementById("dialer-call").addEventListener("click", e => {
            new AudioContext().resume()
            dialer.connect({ params: { dial: this.number() } }).then(call => {
                this.buttons().split("").forEach((button) => {
                    document.getElementById(`dial-${button}`).addEventListener("click", e => { call.sendDigits(button) })
                })
            }).catch(error => console.log(error))
        })
        /* Adds click event listener to hangup button */
        document.getElementById("dialer-hangup").addEventListener("click", e => {
            dialer.disconnectAll();
        })
        /* Registers twilio device */
        dialer.register()
    }
}

const Queue = {
    token() { return this.el.dataset.token },
    queue() { return this.el.dataset.queue },
    buttons() { return this.el.dataset.buttons },
    mounted() {
        /* Set up Twilio device with token */
        const queue_dialer = new Device(this.token())
        /* Let us know when the client is ready. */
        queue_dialer.addListener("registered", (device) => {
            $("#queue-log").html(`
            <div class="good-status-dot group">
                <i class="flex hero-queue-list hover:animate-pulse"></i>
                <span class="queue-status-tooltip">In ${this.queue()} Queue</span>
            </div>
            `);
        });
        /* Report any errors on the screen */
        queue_dialer.addListener("error", function (error) {
            $("#queue-log").html(`
            <div class="bad-status-dot group">
                <i class="flex hero-queue-list hover:animate-pulse"></i>
                <span class="queue-status-tooltip">${error.message}</span>
            </div>
            `);
        });
        /* Handle when a call is incoming */
        queue_dialer.addListener("incoming", function (call) {
            $("#queue-log").text("Incoming connection from " + call.parameters.From);
            call.accept()
            this.buttons().split("").forEach((button) => {
                document.getElementById(`dial-${button}`).addEventListener("click", e => { call.sendDigits(button) })
            })
        })
        /* Adds click event listener to work queue button */
        document.getElementById("queue-call").addEventListener("click", e => {
            new AudioContext().resume()
            queue_dialer.connect({ params: { dial: this.queue() } }).then(call => {
                this.buttons().split("").forEach((button) => {
                    document.getElementById(`dial-${button}`).addEventListener("click", e => { call.sendDigits(button) })
                })
            }).catch(error => console.log(error))
        })
        /* Adds click event listener to hangup button */
        document.getElementById("queue-hangup").addEventListener("click", e => {
            queue_dialer.disconnectAll();
        })
        /* Registers twilio device */
        queue_dialer.register()
    }
}

export {Dialer, Queue}