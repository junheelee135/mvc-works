<template>
  <nav class="navbar navbar-expand-md navbar-light bg-white border-bottom sticky-top">
    <div class="container">
      <router-link class="navbar-brand fw-bold text-dark" to="/">VueProject</router-link>

      <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
        <span class="navbar-toggler-icon"></span>
      </button>

      <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav mx-auto">
            <li class="nav-item">
              <router-link class="nav-link px-3" :to="{ name: 'Home' }" active-class="active-link">Home</router-link>
            </li>
            <li class="nav-item">
              <router-link class="nav-link px-3" :to="{ name: 'About' }" active-class="active-link">About</router-link>
            </li>
            <li class="nav-item">
              <router-link class="nav-link px-3" to="/recipe" active-class="active-link">Recipe</router-link>
            </li>
            <li class="nav-item">
              <router-link class="nav-link px-3" to="/tour" active-class="active-link">Tour</router-link>
            </li>
            <li class="nav-item">
              <router-link class="nav-link px-3" to="/board" active-class="active-link">Board</router-link>
            </li>
        </ul>
      </div>

      <div class="d-flex align-items-center">
        <button class="btn btn-sm btn-outline-secondary rounded-pill px-4">
          Login
        </button>
      </div>
    </div>
  </nav>
</template>

<script setup>

</script>

<style scoped>
.nav-link {
  color: #555;
  font-weight: 500;
  transition: 0.2s;
  border-bottom: 2px solid transparent;  /* 항상 자리 확보 */
}

.nav-link:hover {
  color: #000;
}

.active-link {
  color: #000 !important;
  font-weight: 600;
  border-bottom: 2px solid #000;
}
</style>