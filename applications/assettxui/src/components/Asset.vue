<template>
  <div class="container">
    <div class="box">
      <b-field label="ID" horizontal>
        <b-input v-model="assetuid"></b-input>
      </b-field>
      <b-field label="Appraised Value" horizontal>
        <b-input v-model="appraisedvalue"></b-input>
      </b-field>
      <b-field label="Colo[u]r" horizontal>
        <b-input v-model="color"></b-input>
      </b-field>
      <b-field label="Owner" horizontal>
        <b-input v-model="owner"></b-input>
      </b-field>
      <b-field label="Size" horizontal>
        <b-input v-model="size"></b-input>
      </b-field>

      <div class="level">
        <div class="level-item" v-for="action in actions" :key="action.name">
          <b-button
            @click="submit(action.name)"
            type="is-primary"
            :disabled="action.isDisabled"
          >
            {{ action.text }}</b-button
          >
        </div>
      </div>
    </div>
  </div>
</template>



<script>
/**
 * {"AppraisedValue":101,"Color":"red","ID":"asset7","Owner":"Jean","Size":42}%
 */
export default {
  name: "Asset",
  props: ["uid", "value", "buttonText", "actions"],
  data() {
    return {
      button: "",
      assetuid: "",
      assetObject: "",
      appraisedvalue: "",
      color: "",
      owner: "",
      size: 0,
    };
  },
  methods: {
    submit(action) {
      let payload = {
        action,
        uid: this.assetuid,
        ID: this.assetuid,
        AppraisedValue: this.appraisedvalue,
        Color: this.color,
        Size: parseInt(this.size),
        Owner: this.owner,
      };
      console.log(`Payload:${JSON.stringify(payload)}`);
      this.$emit("submit", payload);
    },
  },
  created() {
    if (this.value) {
      this.assetuid = this.value.ID;
      this.appraisedvalue = this.value.AppraisedValue;
      this.assetObject = this.value;
      this.color = this.value.Color;
      this.owner = this.value.Owner;
      this.size = this.value.Size;
    }
  },
  watch: {
    value() {
      this.assetuid = this.value.ID;
      this.appraisedvalue = this.value.AppraisedValue;
      this.assetObject = this.value;
      this.color = this.value.Color;
      this.owner = this.value.Owner;
      this.size = this.value.Size;
    },
  },
};
</script>


