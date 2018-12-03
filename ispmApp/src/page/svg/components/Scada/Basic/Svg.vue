<template>
<svg v-html="svg" width="100%" height="100%" ref="svgWrap"></svg>
</template>

<script>
export default {
    name: 'ScadaSvg',
    props: {
        svg: {
            type: String
        },
        params: {
            type: Object,
            default: function () {
                return {
                    rotate: 0,
                    colorMask: ''
                }
            }
        }
    },
    data() {
        return {}
    },
    computed: {
        valRotate() {
            return `rotate(${this.params.rotate})`
        }
    },
    methods: {
        initParams() {
            // const s = this.$el.getElementsByTagName('svg')
            // const g = this.$refs.svgWrap
            // if ((this.params.rotate) && (this.params.rotate !== 0) && (this.params.rotate !== '')) {
            //     const strVb = s[0].getAttribute('viewBox')
            //     if (strVb) {

            //         const v = strVb.split(' ')

            //         if (g) {
            //             g.setAttribute('transform', `rotate(${this.params.rotate} 0 0)`)
            //         }
            //     }
            // } else {
            //     if (g) {
            //         g.removeAttribute('transform')
            //     }
            // }
        }
    },
    mounted() {
        this.initParams()
    },
    watch: {
        params() {
            this.initParams()
        }
    }
}
</script>

<style>
svg {
    width: 100%;
    height: 100%;
}

text {
    pointer-events: none;
    user-select: none;
}
</style>
