<template>
  <div class="">
    <div class="container"></div>
    <div>
      <div>
        <b-table
          :focusable="true"
          :striped="true"
          :data="assets"
          :columns="columns"
          @click="rowSelected"
        ></b-table>
      </div>
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

import axios from "axios";
export default {
  name: "GetAllView",
  components: {  },
  data() {
    return {
      value: "",
      buttonText: "Transfer asset...",
      errored: false,
      complete: false,
      submitting: false,
      outputtext: "",
      assets: [],

      columns: [
        {
          field: "ID",
          label: "ID",
        },
        {
          field: "AppraisedValue",
          label: "AppraisedValue",
        },
        {
          field: "Color",
          label: "Colo[u]r",
        },
        { field: "Owner", label: "Owner" },
        { field: "Size", label: "Size" },
      ],
    };
  },
  methods: {
    rowSelected(row) {
      console.log(`Selected row ${row.ID}`);
      this.$router.push({path:`/get/${row.ID}`})
    },
    async getAssets() {
      try {
        console.log("Submitting getAsset");

        //curl --header "X-Api-Key: ${SAMPLE_APIKEY}" http://localhost:4004/api/assets/asset7
        this.submitting = true;
        const instance = axios.create({
          baseURL: "http://localhost:4004/api",
          headers: { "X-Api-Key": "1543e14a-d28b-4903-b4d1-f0061ee44053" },
        });
        let retval = await instance.get(`assets`);

        console.log(retval);
        let response = retval.data;
        if (!response) {
          this.outputtext = "No such asset";
        } else {
          this.assets = response;
          this.outputtext = `${this.assets.length} assets retrieved.`;
        }

        this.complete = true;
        setTimeout(()=>this.complete=false,5000)
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
  },
  async created() {
    await this.getAssets();
  },
};
</script>