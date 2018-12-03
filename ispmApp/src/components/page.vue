<!--page-->
<!--@author LiFanLingJue-->
<!--@date 2017/11/11-->
<template lang="html">
  <div class="tmsPage c_flex c_direction_v">
    <slot name="header"></slot>
    <div :style="{padding: outPadding}" class="body-content c_flex_1">
      <slot name="content"></slot>
    </div>
    <slot name="footer"></slot>

    <slot name="sidebar"></slot>
  </div>
</template>

<script>
export default {
  props: {
    outPadding: {
      type: String,
      // default: '0 .1rem'
    }
  },
  methods: {},
  created() {

  }
}
</script>

<style lang="less" type="text/less" scoped>
.tmsPage {
  height: 100%;
  .body-content {
    position:relative; 
    overflow: auto; 
  }
}
</style>
