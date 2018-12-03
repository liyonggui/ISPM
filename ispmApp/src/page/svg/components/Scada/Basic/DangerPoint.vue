<template>
<svg ref="panel" @contextmenu="contextmenu" t="1532504106147" class="icon" style="" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="10022" xmlns:xlink="http://www.w3.org/1999/xlink" width="128" height="128">
<path d="M502.832 232.896m-16 0a16 16 0 1 0 32 0 16 16 0 1 0-32 0Z" :fill="changeColor(params.status)" p-id="10023">
</path><path d="M490.112 277.04h25.424v287.504h-25.424z" :fill="changeColor(params.status)" p-id="10024"></path>
<path d="M502.832 32.224c-197.552 0-357.696 160.128-357.696 357.68 0 286.448 218.24 279.36 357.696 603.216 139.44-323.84 357.68-316.768 357.68-603.216 0-197.568-160.144-357.68-357.68-357.68zM241.872 599.84L499.488 122.224 763.776 599.84H241.872z" :fill="changeColor(params.status)" p-id="10025"></path>
</svg>
</template>

<script>
import ScadaBase from "./Base.vue";

export default {
    extends: ScadaBase,
    name: "DangerousPoint",
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
                   status:"danger_status_1" 
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
        contextmenu(e)
        {
           this.$emit('contextmenu', e)
        }
    },
    mounted() {

    }
};
</script>
