<template>
<div class="not_found_div mint-loadmore-bottom">
    <img src="../assets/no_data.png" class="not_found_image" />
    <span class="not_found_text">{{title}}</span>
</div>
</template>

<script>
export default {
    props: {
        title: {
            type: String,
            default: "没有找到数据"
        }
    }
}
</script>

<style lang="less" scoped>
.not_found_div {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    color: darkgray;
    flex-direction: column;
    height: 80%;
}

.not_found_image {
    height: 1rem;
}

.not_found_text {
    font-size: .15rem;
}
</style>
