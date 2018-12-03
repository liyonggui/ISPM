<template>
<svg ref="panel" @contextmenu="contextmenu">
 <!-- <defs>
        <radialGradient id="two" cx="0%" cy="0%" r="70%" >
        <stop offset="0%" style="stop-color:rgb(230,0,126);stop-opacity:0.5"/>
        <stop offset="50%" style="stop-color:rgb(231,73,5);stop-opacity:0.5" />
        <stop offset="100%" style="stop-color:rgb(231,153,5);stop-opacity:0.5" />
        </radialGradient>
        <radialGradient id="pad" xlink:href="#two" spreadMethod="pad"/>
        <radialGradient id="repeat" xlink:href="#two" spreadMethod="repeat"/>
        <radialGradient id="reflect" xlink:href="#two" spreadMethod="reflect"/>
    </defs>
  
      <rect
       style="fill: url(#polkadot);fill:url(#reflect);stroke: black"
        :stroke="params.stroke || 'none'"
        :stroke-width="params.strokeWidth"
        rx="500"
        ry="500"
        stroke-position="inside"
        width="96%"
        height="96%"
        x="2%"
        y="2%"/> -->
     <!-- <rect
        fill="black"
        fill-opacity="1"     
        rx="500"
        ry="500"
        width="30"
        height="30"
        x="40%"
        y="40%"/> -->
        <!-- <path d="
        M cx - r, cy
        a r,r 0 1,0 (r * 2),0
        a r,r 0 1,0 -(r * 2),0
    "/> -->

    
      <circle v-if="params.radius<=1"  :fill="changeColor(params.rail_type)" :cx="circleCenter" :cy="circleCenter" r="8" />
      <circle   fill="#fe6262" fill-opacity="0.5" :cx="circleCenter" :cy="circleCenter" :r="circleCenter-1.5" />
      <!-- <rect  
        fill="#fe6262"
        fill-opacity="0.5"
        :stroke="params.stroke || 'none'"
        :stroke-width="params.strokeWidth"
        rx="500"
        ry="500"
        stroke-position="inside"
        width="100%"
        height="100%"
 /> -->
  </svg>
</template>

<script>
import ScadaBase from "./Base.vue";

export default {
    extends: ScadaBase,
    name: "ScadaPanel",
    props: {
        value: {
            type: Object,
            default: function () {
                return {
                    val1: 0
                };
            }
        },
        params: {
            type: Object,
            default: function () {
                return {
                    // stroke: "#000",
                    // strokeWidth: 0,
                    // background: "#CCC",
                    // cornerRadius: 500,
                    rail_type: '1',
                    //半径
                    radius: '1',
                };
            }
        }
    },
    data() {
        return {
            fill: "red",
            circleCenter: 100
        };
    },
    computed: {
        //      bgColor() {
        //        return (this.params.background || 'none')
        //      }
    },
    watch: {
        'params.radius' (val) {
            this.circleCenter = this.$refs.panel.clientHeight / 2;
        }
    },
    methods: {
        changeColor(val) {
            switch (val) {
                // case 'rail_type_1':
                //     return "red"
                // case 'rail_type_2':
                //     return "yellow"
                // case 'rail_type_3':
                //     return "blue"
                // case 'rail_type_4':
                //     return "darkgrey"
                // case 'rail_type_5':
                //     return "black"
                // case 'rail_type_6':
                //     return "pink"
                // case 'rail_type_7':
                //     return "blue"
                default:
                    return "red"
            }
        },
        contextmenu(e)
        {
           this.$emit('contextmenu', e)
        }
    },
    mounted() {

        this.circleCenter = this.$refs.panel.clientHeight / 2;

    }
};
</script>
