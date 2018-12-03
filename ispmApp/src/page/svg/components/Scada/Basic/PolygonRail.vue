<template>
<svg ref="polygonRail" :viewBox="viewBox" :height="height" :width="width" @click="addPoint" @dblclick="clearPoints" @contextmenu="contextmenu" :style="svgStyle" @mouseleave="endDraw">
  
    <polygon 
      :points="pointsString" 
      :fill="fill" 
      :fill-opacity="fillOpacity" 
      :stroke="stroke" 
      :stroke-width="strokeWidth" />
  
    <circle 
      v-for="point in points" 
      :cx="point.x" 
      :cy="point.y" 
      :r="pointsRadius" 
      :fill="getPointFill(point)" 
      :fill-opacity="getPointFillOpacity(point)" 
      @click="removePointHoveringOn" 
      @mouseenter="hoveringOn(point)" 
      @mouseleave="hoveringOn(null)"
       />

  </svg>
</template>

<script>
export default {

    name: 'polygon-editor',

    props: {
        params: {
            type: Object,
            default: function () {
                return {
                    point: '',
                    viewBox:'',
                    rail: '1',
                    //半径
                    radius: '1',
                };
            }
        },
        pointValue: {
            type: String,
            default: null
        },
        height: {
            type: String,
            default: "100%"
        },
        width: {
            type: String,
            default: "100%"
        },
        pointsRadius: {
            type: Number,
            default: 5
        },
        pointsHoverColor: {
            type: String,
            default: "red"
        },
        pointsColor: {
            type: String,
            default: "teal"
        },
        fill: {
            type: String,
            default: "#fe6262"
        },
        fillOpacity: {
            type: Number,
            default: 0.5
        },
        stroke: {
            type: String,
            default: "gray"
        },
        strokeWidth: {
            type: Number,
            default: 1
        },
        backgroundImage: {
            type: String,
            default: null
        }
    },

    data() {
        return {
            points: this.extractPoints(this.params.point),
            pointHoveringOn: null,
            drawable: this.params.point == '',
            viewBox: this.params.viewBox
        }
    },

    computed: {
        hasPoints() {
            return this.points && this.points.length > 0;
        },
        lastPoint() {
            if (this.hasPoints) {
                return this.points[this.points.length - 1];
            }
            return null;
        },
        pointsString() {
            let pointStrings = this.points.map(function (point) {
                return point.x + ',' + point.y;
            }, this);
            return pointStrings.join(' ');
        },
         
        svgStyle() {
            let style = '';
            if (this.backgroundImage) {
                style += 'background:url("' + this.backgroundImage + '") no-repeat left top'
            }
            return style;
        }

    },

    watch: {
        // pointsString() {
        //   this.$emit('input', this.pointsString)
        // }
    },

    methods: {
        extractPoints() {

            console.log("this.params.point" + this.params.point);
            const valuePattern = /^(\d+,\d+ )*\d+,\d+$/;
            let points = [];
            if (!this.params.point) {
                return points;
            }

            if (!valuePattern.test(this.params.point)) {
                return points
            }

            this.params.point.split(' ').forEach(point => {
                points.push({
                    x: parseInt(point.split(',')[0], 10),
                    y: parseInt(point.split(',')[1], 10),
                });
            }, this);
            return points;
        },
        addPoint(evt) {
            if (this.drawable) {
                this.viewBox = '0 0 ' + this.params.radius * this.params.lengthR + ' ' + this.params.radius * this.params.lengthR
                this.points.push({
                    x: evt.offsetX,
                    y: evt.offsetY
                })
            }
        },
        removePointHoveringOn(evt) {
            if (!this.pointHoveringOn) {
                return;
            }
            evt.stopImmediatePropagation()
            this.points.splice(this.points.indexOf(this.pointHoveringOn), 1)
        },
        clearPoints(evt) {
            this.drawable = true
            this.points = []
            evt.preventDefault()
        },
        contextmenu(evt) {
            this.$emit('contextmenu', evt)
        },
        getPointFill(point) {
            if (point === this.pointHoveringOn) {
                return this.pointsHoverColor
            }
            return this.pointsColor
        },
        getPointFillOpacity(point) {
            if ((point === this.pointHoveringOn || point === this.lastPoint) && this.drawable == true) {
                return 1;
            }
            return 0;
        },
        hoveringOn(point) {
            this.pointHoveringOn = point
        },
        endDraw() {

            if (this.points.length > 2 && this.drawable ==true) {
                this.drawable = false
                this.$emit('input', {point:this.pointsString,viewBox:this.viewBox})
            }
        }
    },

    mounted() {
        //this.viewBox = '0 0 ' + this.params.radius * this.params.lengthR + ' ' + this.params.radius * this.params.lengthR
    }

}
</script>
