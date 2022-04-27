<template>
    <section>
        <div class="buttons">
            <b-button tag="router-link"
                to="/get"
                type="is-link">
                Worth with Asset by ID
            </b-button>
            <b-button tag="router-link"
                to="/getall"
                type="is-link">
                Get All Assets
            </b-button>            
            <b-button tag="router-link"
                to="/create"
                type="is-info">
                Create Asset
            </b-button>
            <b-button tag="router-link"
                to="/txstatus"
                type="is-secondary">
                Transaction Status
            </b-button> 

        </div>
    </section>
</template>

<script>

export default {
  name: 'MainView',
  components: {
  }
}
</script>

