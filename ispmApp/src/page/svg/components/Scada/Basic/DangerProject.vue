<template>
<svg ref="panel" @contextmenu="contextmenu" t="1534141470854" class="icon" style="" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="4250" xmlns:xlink="http://www.w3.org/1999/xlink" width="39" height="39"><defs> 
 

</defs><path d="M982.1 590.1l-36.6 36.7L832 513.2l36.6-36.7c20.9-20.9 54.8-20.9 75.6 0l37.8 37.9c21 20.9 21 54.8 0.1 75.7zM400 837.1H66.6c-45.3 0-52.5-100.8-21.5-133.8L417.2 24.8c31-33.1 81.4-33.1 112.4 0L775 471 400 837.1z m128.3-568.7c0-26.2-20-47.5-44.6-47.5s-44.6 21.3-44.6 47.5V490c0 26.2 20 47.5 44.6 47.5s44.6-21.3 44.6-47.5V268.4zM484 601c-24.6 0-44.6 21.3-44.6 47.5s20 47.5 44.6 47.5 44.6-21.3 44.6-47.5-20-47.5-44.6-47.5z m3 260l111 111c-10 7.3-21.6 11.2-33.4 10.6L435.1 1024l41.4-129.7c-0.6-11.8 3.2-23.3 10.5-33.3z m306-308.8l113.5 113.6-275.2 275.3-113.5-113.4L793 552.2z" :fill="changeColor(params.status)" p-id="4251"></path></svg>
</template>

<script>
import ScadaBase from "./Base.vue";

export default {
    extends: ScadaBase,
    name: "DangerProject",
    props: {
        value: {
            type: Object,
            default: function () {
                return {

                };
            }
        },
        params: {
            type: Object,
            default: function () {
                return {
                    status: "danger_status_1"
                };
            }
        }
    },
    data() {
        return {

        };
    },
    computed: {

    },
    watch: {

    },
    methods: {
        changeColor(val) {
            switch (val) {
                case 'danger_status_1':
                    return "#339900"
                case 'danger_status_2':
                    return "red"
                case 'danger_status_3':
                    return "#FFCC00"
                case 'danger_status_4':
                    return "darkgrey"
                default:
                    return "#339900"

            }
        },
        contextmenu(e) {
            this.$emit('contextmenu', e)
        }
    },
    mounted() {

    }
};
</script>
