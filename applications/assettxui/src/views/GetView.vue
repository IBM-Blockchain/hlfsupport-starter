<template>
  <div class="">
    <div class="container">
      <p class="subtitle">Please enter the asset id to work with</p>
    </div>
    <div>
      <Asset
        @submit="submit"
        v-bind:value="value"
        v-bind:actions="actions"
      ></Asset>
    </div>

    <div class="section">
    <section v-if="errored" class="notification is-danger is-light">
      <p>Ain't working...</p>
      <p>{{ response }}</p>
    </section>

    <section v-if="complete" class="notification is-success is-light">
      <p>{{ outputtext }}</p>
    </section>
    </div>
  </div>
</template>

<script>
import Asset from "../components/Asset.vue";
import axios from "axios";
export default {
  name: "GetView",
  components: { Asset },
  data() {
    return {
      value: "",
      buttonText: "Get asset...",
      actions: [
        { name: "get", text: "Get Asset...", isDisabled: false },
        { name: "update", text: "Update Asset...", isDisabled: true },
        { name: "transfer", text: "Transfer Asset...", isDisabled: true },
        { name: "delete", text: "Delete Asset...", isDisabled: true },
      ],
      errored: false,
      complete: false,
      submitting: false,
      outputtext: "",
    };
  },
  created() {
    // watch the params of the route to fetch the data again
    this.$watch(
      () => this.$route.params,
      async () => {
        if (this.$route.params["id"]) {
          await this.get({ uid: this.$route.params["id"] });
          console.log("Route params");
          console.log(this.$route.params);
          console.log("Route params--------------------");
        }
      },
      // fetch the data when the view is created and the data is
      // already being observed
      { immediate: true }
    );
  },
  methods: {
    async get(payload) {
      try {
        //curl --header "X-Api-Key: ${SAMPLE_APIKEY}" http://localhost:4004/api/assets/asset7
        this.submitting = true;
        const instance = axios.create({
          baseURL: "http://localhost:4004/api",
          headers: { "X-Api-Key": "1543e14a-d28b-4903-b4d1-f0061ee44053" },
        });
        let retval = await instance.get(`assets/${payload.uid}`);

        console.log(retval);
        let response = retval.data;
        if (!response) {
          this.outputtext = "No such asset";
        } else {
          this.value = response;
          this.outputtext = "Success, asset retrieved";
        }
        this.actions
          .filter((a) => a.name === "update" || a.name === "transfer")
          .forEach((a) => (a.isDisabled = false));
        this.complete = true;
        setTimeout(()=>this.complete=false,3000)
      } catch (e) {
        this.value = {};
        this.errored = true;
        console.log(e);
        if (e.response) {
          console.log(e.response.data); // => the response payload
        }
        this.response = e;
      } finally {
        this.submitting = false;
      }
    },
    async transfer(payload) {
      try {
        let patchRequest = [
          { op: "replace", path: "/owner", value: payload.Owner },
        ];

        this.submitting = true;
        let retval = await this.$http.patch(
          `http://localhost:4004/api/assets/${payload.ID}`,
          patchRequest,
          {
            headers: {
              "X-Api-Key": "1543e14a-d28b-4903-b4d1-f0061ee44053",
              "Content-Type": "application/json",
            },
          }
        );
        // let response = retval.response;
        const responseData = retval.data;
        console.log(`Response ${JSON.stringify(retval)}`);

        this.$store.commit("addTx", responseData);
        this.outputtext = `Transfer request submitted Job ${responseData.jobId}`;
        this.complete = true;
        setTimeout(()=>this.complete=false,5000)
      } catch (e) {
        this.errored = true;
        console.log(e);
        if (e.response) {
          console.log(e.response.data); // => the response payload
          this.response = e.response.data.message;
          this.errorList = e.response.data.errors;
        }
      } finally {
        this.submitting = false;
      }
    },
    async update(payload) {
      console.log(JSON.stringify(payload));
    },
    async submit(payload) {
      console.log("Submitting.." + JSON.stringify(payload));

      switch (payload.action) {
        case "get":
          await this.get(payload);
          break;
        case "transfer":
          await this.transfer(payload);
          break;
        default:
          break;
      }
    },
  },
};
</script>