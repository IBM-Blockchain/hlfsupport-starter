<template>
  <div class="">
    <div class="container">
      <p class="subtitle">Please enter the asset id to transfer and the new owner</p>
    </div>
    <div>
      <Asset
        @submit="transferAsset"
        v-bind:uid="uid"
        v-bind:value="value"
        v-bind:buttonText="buttonText"
      ></Asset>
    </div>

    <section v-if="errored">
      <p>Ain't working...</p>
      <p>{{ response }}</p>
      <div v-for="e in errorList" :key="e.param">
       {{e.param}} {{e.msg}} {{e.value}}
      </div>



    </section>

    <section v-if="complete">
      <p>{{ outputtext }}</p>
    </section>
  </div>
</template>

<script>
import Asset from "../components/Asset.vue";

export default {
  name: "TransferView",
  components: { Asset },
  data() {
    return {
      uid: "",
      value: "ddd",
      buttonText: "Transfer asset...",
      errored: false,
      complete: false,
      submitting: false,
      outputtext: "",
      errorList: "",
    };
  },
  methods: {
    async transferAsset(payload) {
      
      try {
        console.log("Submitting trasnfer");
        let patchRequest = [{"op":"replace","path":"/owner","value":payload.Owner}]
        console.log(JSON.stringify(patchRequest));
        this.submitting = true;
        let retval = await this.$http.patch(
          `http://localhost:4004/api/assets/${payload.ID}`,
          patchRequest,
          { headers:{'X-Api-Key': '1543e14a-d28b-4903-b4d1-f0061ee44053','Content-Type':'application/json'} }
        );
        // let response = retval.response;

        console.log(retval);

        this.complete = true;
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
  },
};
</script>