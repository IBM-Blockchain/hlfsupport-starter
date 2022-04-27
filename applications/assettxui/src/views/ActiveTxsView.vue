<template>
  <div class="">
    <div>
      <b-table :data="activeTxs" :columns="columns"></b-table>
    </div>

    <section v-if="errored">
      <p>Ain't working...</p>
      <p>{{ response }}</p>
      <div v-for="e in errorList" :key="e.param">
        {{ e.param }} {{ e.msg }} {{ e.value }}
      </div>
    </section>

    <section v-if="complete">
      <p>{{ outputtext }}</p>
    </section>
  </div>
</template>

<script>
export default {
  name: "ActiveTxsView",
  components: {},
  computed: {
    activeTxs() {
      return this.$store.state.activeTxs;
    },
  },
  data() {
    return {
      columns: [
        {
          field: "status",
          label: "Status",
        },
        {
          field: "jobId",
          label: "Job ID",
        },
        {
          field: "timestamp",
          label: "Time",
        },
      ],
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
        let patchRequest = [
          { op: "replace", path: "/owner", value: payload.Owner },
        ];
        console.log(JSON.stringify(patchRequest));
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