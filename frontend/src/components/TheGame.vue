<script lang="ts">
import { ref, onMounted } from "vue";
import { useUserStore } from "../stores/userStore";

export default {
  name: "TheGame",
  setup() {
    const userStore = useUserStore();
    const initialScreen = ref(null);
    const gameCodeInput = ref(null);
    const gameCodeSpec = ref(null);

    const gameScreen = ref(null);
    const msgBox = ref(null);
    const canvas = ref(null);

    return {
      initialScreen,
      gameCodeInput,
      gameCodeSpec,
      gameScreen,
      msgBox,
      canvas,
      userStore,
    };
  },
  props: {
    user: Object,
    socket: Object,
  },
  data() {
    return {
      title: "Game Room",

      score: {},
      gameStatus: String("idle"),
      // socket: ref(),
      ctx: null,
      gameActive: Boolean(false),
      hasBeenInvited: Boolean(false),
    };
  },
  created() {
    this.socketSetter();
  },
  mounted() {
    this.reset();
  },
  unmounted() {
    if (!this.hasBeenInvited)
      this.socket.emit("test");

    this.socket.removeAllListeners();
  },

  methods: {
    socketSetter() {
      //--> ALTERNATIVE this.userStore.socket.on("connect", () => {console.log(` userStoreSocket working`);})
      this.socket.on("connect", () => {
        this.gameStatus = "idle";
      });
      this.socket.on("reset", this.handleReset);
      this.socket.on("init", this.handleInit);
      this.socket.on("gameState", this.handleGameState);
      this.socket.on("gameOver", this.handleGameOver);
      this.socket.on("unknownCode", this.handleUnknownCode);
      this.socket.on("tooManyPlayers", this.handleTooManyPlayers);
      this.socket.on("paused", this.handlePause);
      this.socket.on("notify", this.handleNotification);
      this.socket.on("broadcastMsg", this.receiveMsg);
      this.socket.on("disconnection", this.handleDisconnection);
      this.socket.on("startGameAnimation", this.startGameAnimation);
      this.socket.on("invit", this.invitationRecu);
      this.socket.on("acceptInvit", this.acceptInvit);
      this.socket.on("pushLiveGame", this.pushLiveGame);
      this.socket.on("samePlayer", (arg1, callback) => {
        callback({
          status: alert("test"),
        });
      });
    },

    joinQueue(playWithPowerUP: boolean) {
      this.socket.emit("joinQueue", playWithPowerUP);
      // this.gameState = "play";
    },

    createNewGame() {
      this.socket.emit("newGame");
    },

    invitationRecu(adversaire, code) {
      this.hasBeenInvited = true;
      if (
        confirm(
          adversaire.username + ", vous défie au pong : lancer la partie ?"
        )
      ) {
        this.socket.emit("newGame", code);
        this.socket.emit("acceptInvit", adversaire, code);
        this.$router.push("Chat");
      } else this.socket.emit("declineGameInvit", adversaire);
    },

    acceptInvit(roomCode) {
      this.socket.emit("joinGame", roomCode);
    },

    handleJoinGame() {
      const code = this.gameCodeInput?.value;
      this.socket.emit("joinGame", code);
    },

    handleReset() {
      this.reset();
    },

    handleSpecGame() {
      const code = this.gameCodeSpec.value;
      this.socket.emit("spec", code);
      this.init();
    },

    init() {
      this.initialScreen.style.display = "none";
      this.gameScreen.style.display = "block";
      this.ctx = this.canvas.getContext("2d");
      this.canvas.width = 750;
      this.canvas.height = 590;
      this.ctx.fillStyle = "#703ab8";
      this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);

      document.addEventListener("keydown", this.keydown);
      document.addEventListener("keyup", this.keyup);
      this.gameActive = true;
    },

    keydown(e) {
      if (!this.socket.connected) return;
      // e.preventDefault();
      // e.stopPropagation();
      this.socket.emit("keydown", e.keyCode);
      // if (e.key == "d") this.socket.disconnect();
      // if (e.key == "f") this.socket.connect();
    },

    keyup(e) {
      if (!this.socket.connected) return;
      // e.preventDefault();
      // e.stopPropagation();
      this.socket.emit("keyup", e.keyCode);
    },

    async startGameAnimation() {

      for (let cntDown = 5; cntDown > 0; --cntDown)
        for (let index = 0; index < 100; ++index) {
          this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
          this.ctx.font = index.toString() + "px Calibri,Geneva,Arial";
          this.ctx.strokeStyle = "rgb(0,0,0)";
          this.ctx.strokeText(
            String(cntDown),
            this.canvas.width / 3 - index / 3,
            this.canvas.height / 3 + index / 3
          );
          // await this.sleep(10);
        }

      if (this.playerNumber == 1) this.socket.emit("startGame");
    },

    sleep(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms));
    },

    paintGame(state) {
      if (!this.canvas) return;
      const grid = 15;
      // clear canvas
      this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
      // draw paddles
      this.ctx.fillStyle = "#703ab8";
      this.ctx.fillRect(grid, state.players[0].y, 15, state.players[0].paddleH);
      this.ctx.fillRect(
        this.canvas.width - 2 * grid,
        state.players[1].y,
        15,
        state.players[1].paddleH
      );

      // draw walls
      this.ctx.fillStyle = "#e4d8f5";
      this.ctx.fillRect(0, 0, this.canvas.width, grid);
      this.ctx.fillRect(
        0,
        this.canvas.height - grid,
        this.canvas.width,
        this.canvas.height
      );

      // draw dotted line down the middle
      for (let i = grid; i < this.canvas.height - grid; i += grid * 2) {
        this.ctx.fillRect(this.canvas.width / 2 - grid / 2, i, grid, grid);
      }

      // draw ball
      this.ctx.fillStyle = "#703ab8";
      this.ctx.fillRect(state.ball.x, state.ball.y, 15, 15);

      // draw PowerUps (if any)
      if (state.powerUp[0].x > 0) {
        this.ctx.fillStyle = state.powerUp_t;
        this.ctx.fillRect(state.powerUp[0].x, state.powerUp[0].y, 15, 15);
        this.ctx.fillRect(state.powerUp[1].x, state.powerUp[1].y, 15, 15);
      }

      // draw scrore
      this.ctx.font = "20pt Calibri,Geneva,Arial";
      this.ctx.strokeStyle = "#703ab8";
      this.ctx.strokeText(
        String(this.score.p1),
        this.canvas.width / 2 - 40,
        40
      );
      this.ctx.strokeText(
        String(this.score.p2),
        this.canvas.width / 2 + 25,
        40
      );
    },

    handleInit(number) {
      this.playerNumber = number;
      this.init();
    },
    handleGameState(gameState) {
      if (!this.gameActive) {
        return;
      }
      gameState = JSON.parse(gameState);
      this.score = gameState.score;
      if (this.gameStatus !== "opponentLeft" && this.gameStatus !== "paused")
        requestAnimationFrame(() => this.paintGame(gameState));
      this.gameStatus = "play";
    },
    handleGameOver(data) {
      if (!this.gameActive) {
        return;
      }
      this.gameStatus == "idle";
      document.removeEventListener("keydown", this.keydown);
      document.removeEventListener("keyup", this.keydown);

      this.gameActive = false;
      this.$notify({
        position: "center",
        title: "The Game has reach its end..",
        text: data + " has Won !!",
        duration: 6000,
      });
    },

    handleUnknownCode() {
      this.reset();
      alert("Already playing or in queue");
    },

    handleTooManyPlayers() {
      this.reset();
      alert("This game is already in progress");
    },

    handleDisconnection() {
      this.gameStatus = "opponentLeft";
      this.$notify({
        title: "Important message",
        text: "Your opponent disconnected\nYou can wait till he come back or claim victory",
        duration: 6000,
      });
      // alert("Your Opponent disconnected, you can wait till he come back or claim victory");
    },

    handlePause(msg) {
      this.socket.emit("pause");
    },

    handleNotification(msg) {
      this.$notify(msg);
    },

    reset() {
      this.gameStatus = "idle";
      console.log('reset')

      if (!this.hasBeenInvited)
      {
        this.socket.emit("test");
      }
      this.gameStatus =
        this.gameStatus == "play" || this.gameStatus == "paused"
          ? this.gameStatus
          : "idle";
      this.playerNumber = null;
      if (this.gameCodeInput) this.gameCodeInput.value = "";
      if (this.gameCodeSpec) this.gameCodeSpec.value = "";
      this.initialScreen.style.display = "block";
      this.gameScreen.style.display = "none";
    },
    liveGame() {
      this.socket.emit("getLiveGame", (response) => {
      });
    },
    pushLiveGame(liveGame) {
        this.liveGame = liveGame;
    },
  },
};
</script>

<template>
  <section class="vh-100">
    <div class="container h-100">
      <div ref="initialScreen" class="h-100">
        <div
          class="
            d-flex
            flex-column
            align-items-center
            justify-content-center
            h-100
          "
        >
          <p style="font-size: 20px">
            Join a queue to play agains other players:
          </p>
          
          <div style="display: flex; flex-direction: column">
            <button class="wrapper" @click="joinQueue(false)">
              <div class="icon">👾</div>
              <div>
                <p class="title">Play Basic Pong</p>
                <p class="explenation">Regular 2v2 pong</p>
              </div>
            </button>
            <button class="wrapper" @click="joinQueue(true)">
              <div class="icon">🚀</div>
              <div>
                <p class="title">Play PowerUP Pong!</p>
                <p class="explenation">Play pong with increased features</p>
              </div>
            </button>
          </div>
        </div>
      </div>

      <div ref="gameScreen" id="gameScreen" class="h-100">
        <div
          class="
            d-flex
            flex-column
            align-items-center
            justify-content-center
            h-100
          "
        >
          <div v-if="this.gameStatus == 'idle'" class="name-title">
            Wating for another player...
          </div>

          <canvas
            ref="canvas"
            class="game-canvas"
            v-bind:class="{
              'display-none': this.gameStatus == 'idle',
            }"
          ></canvas>
          <button
            v-if="this.gameStatus == 'play' || this.gameStatus == 'paused'"
            type="submit"
            class="btn btn-success"
            ref="pauseButton"
            v-on:click="handlePause()"
          >
            {{ this.gameStatus == "play" ? "⏸ Pause" : "▶️ play" }}
          </button>
          <button
            type="submit"
            class="btn btn-success"
            ref="notifyButton"
            v-if="this.gameStatus === 'opponentLeft'"
            v-on:click="claimVictory"
          >
            claimVictory
          </button>
          <button
            type="submit"
            class="btn btn-success"
            ref="notifyButton"
            v-if="!this.gameActive"
            v-on:click="reset"
          >
            ← Go back ←
          </button>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.wrapper {
 display: flex;
 /* justify-content: center; */
 align-items: center;
 background-color: rgba(121, 61, 204, 0.155);
 border-radius: 10px;
 margin-top: 30px;
border: none;  
cursor: pointer;
padding: 10px;
font-size: 15px;
box-shadow: 0 0 6px rgba(213, 183, 255, 0.2),
  0 0 30px rgba(219, 202, 243, 0.34), 0 0 12px rgba(211, 193, 236, 0.52),
  0 0 21px rgba(211, 193, 236, 0.92), 0 0 34px rgba(211, 193, 236, 0.78),
  0 0 54px rgba(211, 193, 236, 0.92);
  transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
}

.wrapper:hover {
 background-color: rgba(121, 61, 204, 0.317);
}

.icon {
  font-size: 50px;
  margin-right: 30px;
}

.title {
  font-size: 25px;
    font-weight: bold;

}

.game-canvas {
  margin: auto;
  width: 100%;
  border-radius: 10px;
  box-shadow: 0 0 6px rgba(120, 61, 204, 0.92), 0 0 30px rgba(94, 14, 206, 0.34),
    0 0 12px rgba(211, 193, 236, 0.52), 0 0 21px rgba(211, 193, 236, 0.92),
    0 0 34px rgba(211, 193, 236, 0.78), 0 0 54px rgba(211, 193, 236, 0.92); /* box-shadow: 0 3px 6px rgba(0, 0, 0, 0.16), 0 3px 6px rgba(0, 0, 0, 0.23); */
}

#gameScreen {
  display: none;
}

.chat {
  margin-top: 40px;
  height: 40px;
  color: blueviolet;
  border: 1px;
  border-radius: 25px;
}

textarea {
  border: 3px solid #703ab8;
  border-radius: 13px;
  width: 100%;
  padding: 10px;
  margin: 10px;
}

.message-box {
  overflow: hidden;
  border: 3px solid #703ab8;
  border-radius: 13px;
  width: 100%;
  height: 300%;
  padding: 10px;
  margin: 10px;
}

.pwd-btn {
  background-color: white;
  border: none;
  color: #703ab8;
  font-weight: bold;
  box-shadow: 0 3px 6px rgba(0, 0, 0, 0.16), 0 3px 6px rgba(0, 0, 0, 0.23);
  border-radius: 3px;
  padding: 6px 15px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
  margin-top: 10px;
  margin: 10px;
  border: 2px solid #703ab8;
}

.display-none {
  height: 0px;
}

.name-title {
  font-size: 50px;
  margin-bottom: 130px;
  text-transform: capitalize;
  text-align: center;
  color: #703ab8;
  font-family: "Send Flowers", cursive;
  margin-bottom: -50px;
  z-index: 30;
  text-shadow: 0 0 6px rgba(120, 61, 204, 0.92),
    0 0 30px rgba(94, 14, 206, 0.34), 0 0 12px rgba(211, 193, 236, 0.52),
    0 0 21px rgba(211, 193, 236, 0.92), 0 0 34px rgba(211, 193, 236, 0.78),
    0 0 54px rgba(211, 193, 236, 0.92); /* box-shadow: 0 3px 6px rgba(0, 0, 0, 0.16), 0 3px 6px rgba(0, 0, 0, 0.23); */
}

.btn {
  background-color: #703ab8;
  border: none;
  color: white;
  font-weight: bold;
  font-size: large;
  box-shadow: 0 3px 6px rgba(0, 0, 0, 0.16), 0 3px 6px rgba(0, 0, 0, 0.23);
  border-radius: 13px;
  padding: 10px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
  /* margin-left: 10px; */
  margin: auto;
  margin-top: 20px;
  display: block;
}

.game-canvas {
  margin: auto;
  width: 100%;
  border-radius: 10px;
  box-shadow: 0 0 6px rgba(120, 61, 204, 0.92), 0 0 30px rgba(94, 14, 206, 0.34),
    0 0 12px rgba(211, 193, 236, 0.52), 0 0 21px rgba(211, 193, 236, 0.92),
    0 0 34px rgba(211, 193, 236, 0.78), 0 0 54px rgba(211, 193, 236, 0.92); /* box-shadow: 0 3px 6px rgba(0, 0, 0, 0.16), 0 3px 6px rgba(0, 0, 0, 0.23); */
}
</style>
