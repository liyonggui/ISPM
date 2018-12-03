<template>
  <transition name="router-fade" mode="out-in">
    <router-view></router-view>
  </transition>
</template>
<script>
  export default {}
</script>
<style>

  .router-fade-enter-active, .router-fade-leave-active {
	  	transition: opacity .1s;
	}
	.router-fade-enter, .router-fade-leave-active {
	  	opacity: 0;
	}
</style>

<!-- 项目的样式引入 -->
<style src="element-ui/lib/theme-default/index.css"></style>
<style src="perfect-scrollbar/dist/css/perfect-scrollbar.css"></style>
<style src="./style/style.less" lang="less"></style>
<style src="./style/dms.css"></style>
