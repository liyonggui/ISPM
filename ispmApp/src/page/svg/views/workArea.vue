<template>
<div id="workarea" ref="workarea">

    <drop id="canvas" :style="canvasStyle" @drop="handleCompDrop" ref="canvas" :class="{'grid-bg':canvasConfig.showGrid}" style="transform-origin: top left">
        <div id="fill" style="position: absolute;width:100%;height:100%" @click="onCancle"></div>
        <slot name="setting" class="setting"> </slot>
        <dragger v-if="component.show" :draggable="draggable" :resizable="resizable" v-for="component in components.slice().reverse()" :id="component.id" :key="component.id" :active.sync="component.active" :w="component.layout.width" :h="component.layout.height"
            :x="component.layout.x" :y="component.layout.y" :ratio="component.layout.ratio" :zoom="canvasConfig.zoom" class="drag-box" :parent="true" @activated="onActivated(component)" @init="onDraggerChanged" @resizestop="onDraggerChanged" @dragstop="onDraggerChanged">
            <component v-if="component.type === 'scada-svg' " :is="'scada-svg'" class="scada-svg-wrapper" :svg="component.innerSvg" :params="component.params" />
            <component v-else-if="component.type === 'scada-svg-comp'" :is="'scada-svg-comp'" class="scada-svg-wrapper" :name="component.name" :params="component.params" />
            <component id="svg" v-else :is="component.type" @input="handleInputPoint" :value="component.value" :params="component.params" @contextmenu="contextmenu(component)" width="100%" height="100%" />
        <!--危险点等控件审核未成功时显示图片-->
        <div class="unpass" v-if="component.params.auditStatus !='audit_status_3'  && component.type !='sign_type_4'"> </div>
        </dragger>

    </drop>

</div>
</template>

<script>
import Dragger from '../components/Dragger/dragger.vue'
import {
    Drop
} from 'vue-drag-drop'
import {
    polyfill
} from "mobile-drag-drop";
import {
    scrollBehaviourDragImageTranslateOverride
} from "mobile-drag-drop/scroll-behaviour"
import cloneDeep from 'lodash/cloneDeep'
import scadaSvg from '../components/Scada/Basic/Svg.vue'
import scadaSvgComp from '../components/Scada/Basic/SvgComp.vue'
// sign_type_1:危险点 
// sign_type_2_1:圆形围栏  
// sign_type_2_2 多边形围栏 
// sign_type_3:危大工程 
// sign_type_4:文本描述
import sign_type_1 from '../components/Scada/Basic/DangerPoint.vue'
import sign_type_3 from '../components/Scada/Basic/DangerProject.vue'
import sign_type_2_1 from '../components/Scada/Basic/CircleRail.vue'
import sign_type_2_2 from '../components/Scada/Basic/PolygonRail.vue'
import sign_type_4 from '../components/Scada/Basic/Label.vue'

export default {
    components: {
        Dragger,
        Drop,
        scadaSvg,
        scadaSvgComp,

        sign_type_1,
        sign_type_2_1,
        sign_type_2_2,
        sign_type_3,
        sign_type_4

    },
    props: {
        draggable: {
            type: Boolean,
            default: true
        },
        resizable: {
            type: Boolean,
            default: true
        },
        components: null,
        canvasConfig: {
            type: Object,
            default: function () {
                return {
                    width: '0px',
                    height: '0px',
                    background: '#FFF',
                    showGrid: true,
                    zoom: 1
                }
            }
        },
        isShowBgGrid: true
    },
    data() {
        return {}
    },
    computed: {
        canvasStyle() {

            return {
                width: this.canvasConfig.width + 'px',
                height: this.canvasConfig.height + 'px',
                background: this.canvasConfig.bgColor,
                transform: `scale(${this.canvasConfig.zoom})`
            }
        }
    },
    methods: {
        onActivated(component) {
            this.$emit('activated', component.id)
        },
        handleCompDrop(data, e) {
            if (!data) {
                return
            }
            console.log(document.getElementById('workarea'))
            const canvasX = document.getElementById('canvas').offsetLeft
            const canvasY = document.getElementById('canvas').offsetTop
            const scrollX = document.getElementById('workarea').scrollLeft
            const scrollY = document.getElementById('workarea').scrollTop
            const d = cloneDeep(data)
            const r = (d.config.keepRatio) ? (d.config.height / d.config.width) : 0
            const layout = {
                x: Math.round((e.clientX - canvasX + scrollX) / this.canvasConfig.zoom),
                y: Math.round((e.clientY - canvasY + scrollY) / this.canvasConfig.zoom),
                width: d.config.width,
                height: d.config.height,
                ratio: r
            }
            d.layout = layout
            if (d.config.compType) {
                if (d.config.compType === 'svg') {
                    this.$emit('addDropedCompSvg', d)
                    return
                }
            }
            this.$emit('addDropedComp', d)
        },
        onDraggerChanged(guid, x, y, w, h) {
            this.$emit('compLayoutChanged', {
                guid,
                x,
                y,
                w,
                h
            })
        },
        onCancle() {

            this.$emit('compSelCanceled')
        },
        handleInputPoint(val) {
            this.$emit('input', val)
        },
        contextmenu(component) {
            this.$emit('contextmenu', component)
        }
    },
    mounted() {
        document.oncontextmenu = (e) => {　　
            return false;
        }
        document.documentElement.addEventListener('dragenter',
            (event) => {

                event.preventDefault();
            }, true)
    }
}
</script>

<style lang="less">
#workarea {
    flex-grow: 1;
    background-color: #BBB;
    overflow: auto;
}

#workarea::-webkit-scrollbar {
    display: none;
}

#canvas {
    // margin: 2px;
    background-color: #FFF;
    border: 1px solid #999;
    position: relative;
    box-shadow: 1px 1px 5px #999;
    .scada-svg-wrapper {
        width: 100%;
        height: 100%;
        z-index: -1;
    }
}

.drag-box {
    border: 1px solid transparent;
    svg {
        position: absolute;
    }
}

.active {
    border: 1px dashed #43b5ff;
}

.grid-bg {
    transition: background-color 0.2s ease-in-out;
}
.unpass
{
    width: 100%;
    height: 100%;
    background: url('../../../assets/svg/unpass.png') no-repeat;
    background-size:100% 100%;  
}
</style>
