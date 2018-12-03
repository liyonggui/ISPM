<template lang="html">
  <div class="error-page">
    <h2 class="headline text-yellow"> 404</h2>
    <div class="error-content">
      <h3><i class="fa fa-warning text-yellow"></i> Oops! Page not found.</h3>
      <p>
        We could not find the page you were looking for.
        Meanwhile, you may
        <router-link to="/dashboard">return to dashboard</router-link>
        .
      </p>
    </div>
  </div>
</template>

<script>

  export default {}
</script>
