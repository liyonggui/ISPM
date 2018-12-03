<template>
<div id="comp-container">
    <div class="comp-head" :style="collapseStyle" @click="collapsed=!collapsed">
        <span>
        <van-icon style="font-size: 20px;color:white;" name ="icon-zhediezhankai" v-if="!collapsed"/> 
        <van-icon style="font-size: 20px;color:white;" name ="icon-zhedieshouqi"  v-if="collapsed"/> 
         <!-- <i style="font-size: 30px;color:white;" class="van-icon iconfont icon-zhedieshouqi icon-zhediezhankai"   @click="collapsePanel"></i> -->
 
        </span>
    </div>
    <div class="comp-list" v-if="!collapsed">
        <drag v-for="tool in compTools" class="comp-item" v-if="getPermission(tool.config.permission)" :key="tool.id" :transferData="{type:tool.name, config:tool.config, attrs:tool.attrs, params:tool.params }">
            <img class="comp-icon" :src="require('assets/svg/'+tool.name+'.png')" :alt="tool.type">
        </drag>
    </div>

    <!-- <collapse-panel label="空调系统" class="comp-cate" @panelCollapse="onPanelCollapse">
        <div class="comp-list">
          <drag v-for="tool in compToolsEx" class="comp-item" :key="tool.id"
                :transferData="{type:tool.name, name:tool.name, config:tool.config, attrs:[], params:tool.params }">
            <img class="comp-icon comp-icon-svg"
                 :src="tool.imgUrl" :alt="tool.type">
           </drag>
        </div>
      </collapse-panel>
      <collapse-panel label="燃烧系统" class="comp-cate" @panelCollapse="onPanelCollapse">
        <div class="comp-list">
          <drag v-for="tool in compToolsEx2" class="comp-item" :key="tool.id"
                :transferData="{type:tool.name, name:tool.name, config:tool.config, attrs:[], params:tool.params }">
            <img class="comp-icon comp-icon-svg"
                 :src="tool.imgUrl" :alt="tool.type">
          </drag>
        </div>
      </collapse-panel> -->
</div>
</template>

<script>
import {
    Drag
} from 'vue-drag-drop'
import {
    polyfill
} from "mobile-drag-drop";
import {
    scrollBehaviourDragImageTranslateOverride
} from "mobile-drag-drop/scroll-behaviour"
import scadaComps from '../components/Scada/Basic'

polyfill({
    // use this to make use of the scroll behaviour
    dragImageTranslateOverride: scrollBehaviourDragImageTranslateOverride
})
export default {
    components: {
        Drag
    },
    props: {
        pointType: ''
    },
    data() {
        return {
            collapsed: false
        }
    },
    computed: {
        compTools() {
            let listTools = []
            scadaComps.tools.forEach(element => {
                //危大工程_不显示危险点控件
                if (this.pointType == "point_type_1" && element.name != "sign_type_3") {
                    listTools.push(element)
                }
                //危险点_不显示危大工程控件
                else if (this.pointType == "point_type_2" && element.name != "sign_type_1") {
                    listTools.push(element)
                } else if (!this.pointType) {
                    listTools.push(element)
                }

            });
            return listTools
        },
        collapseStyle() {
            return this.collapsed ? 'opacity:0.5' : ''
        },

    },
    methods: {
        onPanelCollapse() {
            this.$events.emit('PanelCollapseChanged', '组件库')
        },
        getPermission(permission) {
            if (permission) {
                return this.$checkPermission(permission)
            } else {
                return true
            }
        },
    }
}
</script>

<style lang="less">
@import "../styles/mixin.less";

#comp-container {
    max-width: 80px;
    right: 0;
    top: 200px;
    overflow: auto;
    padding-right: 2px;
    position: fixed;
    z-index: 100;
}

.panel-subtitle {
    margin: 4px 0;
    padding: 4px 4px 2px 4px;
    line-height: 16px;
}

.tools-panel {
    .comp-cate {
        .title-label {
            margin: 0px 0 4px 0;
            padding: 4px 4px 2px 6px;
            line-height: 16px;
            background-color: #454545;
        }

        .panel-content {
            padding: 0;
            border-bottom: 0;
        }
    }
}

.comp-head {
    max-width: 80px;
    min-width: 60px;
    text-align: center;
    background-color: #454545;
    margin-bottom: 5px;
    margin-left: 12px;
    height: 30px;
    line-height: 30px;
}

.comp-list {
    margin-left: 12px;
    // margin-bottom: 4px;
    display: grid;
    grid-template-columns: repeat(1, 1fr);
    grid-auto-rows: 60px;

    /*grid-template-rows: repeat(3, 1fr);*/
    // grid-column-gap: 2px;
    // grid-row-gap: 2px;
    .comp-item {
        font-size: 10px;
        background-color: #454545;
        text-align: center;
        cursor: pointer;
        color: white;
        // border: 1px solid #666666;
    }
}

.collapse-btn {
    float: right;
}

.comp-icon {
    margin: 10px;
    width: 60%;
    height: 60%;
}

.comp-label {
    width: 100%;
    height: 20px;
    border-top: 1px solid #666666;
}

.comp-icon-svg {
    padding: 5px;
}
</style>
