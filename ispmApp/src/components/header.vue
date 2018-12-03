<!--header-->
<!--@author LiFanLingJue-->
<!--@date 2017/11/10-->
<template>
<div class="header c_flex c_direction_v">
    <div class="blank"></div>
    <div class="content c_flex_1">
        <div style="position: absolute; height: 100%;width:100%;display: flex;flex-direction: row;">
            <div v-if="$slots.title"> 
                <div class="header-left c_flex_1 c_flex c_a_center c_j_center">
                    <slot name="header-left"></slot>
                </div>
                <div class="header-center c_flex_5 c_flex c_a_center c_j_center">
                    <slot name="header-center"></slot>
                </div>
                <div class="header-right c_flex_1 c_flex c_a_center c_j_center">
                    <slot name="header-right"></slot>
                </div>
            </div>
            <div v-if="!$slots.title">
                <div
                    class="van-nav-bar van-hairline--bottom"
                    :class="{ 'van-nav-bar--fixed': fixed }"
                    :style="style"
                >
                    <div
                        class="van-nav-bar__left"
                        @click="$emit('click-left')"
                    >
                        <slot name="left">
                            <icon
                                v-if="leftArrow"
                                class="van-nav-bar__arrow van-icon-arrow-left"
                                name="arrow"
                            />
                            <span
                                v-if="leftText"
                                v-text="leftText"
                                class="van-nav-bar__text"
                            />
                        </slot>
            </div>
            <div class="van-nav-bar__title van-ellipsis">
                <slot name="title">{{ title }}</slot>
            </div>
            <div
                class="van-nav-bar__right"
                @click="$emit('click-right')"
            >
                <slot name="right">
                    <span
                        v-if="rightText"
                        v-text="rightText"
                        class="van-nav-bar__text"
                    />
                </slot>
        </div>
    </div>
</div>
</div>
</div>
</div>
</template>

<script>
export default {}
</script>

<style lang="less" scoped>
.header {
    background-color: #00bdbe;
    background-image: url("../assets/vehicle/head.png");
    background-repeat: no-repeat;
    background-size: 100% 100%;
    height: .55rem;
    .blank {
        height: .05rem;
        width: 100%;
    }
    .content {
        position: relative;
        .header-left {
            height: 100%;
            color: #ffffff;
        }
        .header-center {
            color: #ffffff;
            font-size: .18rem;
            height: 100%;
        }
        .header-right {
            height: 100%;
            color: #ffffff;
        }
    }
}
</style>
