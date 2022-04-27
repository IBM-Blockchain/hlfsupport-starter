<template>
  <div class="section">
    Hello :-)
  </div>
</template>

<script>
import Asset from '../components/Asset';


export default {
  name: 'HelloWorld',
  components: { Asset},
  data() {
    return {
      fred:'fred'
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
