<template>
    <div id="complist_panel" v-show="components.length>0" :style="listHeight" :class="{isHide:clientVisable}">
        <van-list class="page-list">
            <van-row v-for="comp in components" :key="comp.id" v-if="comp.type!= 'scada-svg'" class="page-item">
                <van-col :span="16">
                    <div :class="{isActive:comp.active}" @click="compSelected(comp.id)">
                        {{comp.label}}
                    </div>
                </van-col>
                <van-col style="color:blue" v-if="disabled ==false" :class="{isActive:comp.active}" :span="8">
                    <van-icon  name="delete" :style="getPermission(comp.permission)?'color:red':'color:darkgray'"  @click="actionRemoveCurrentComp(comp)"/> 
                    <van-icon  style="font-size:20px;color:white" name="icon-shangyi" @click="actionMoveToFront(comp.id)"/> 
                    <van-icon  style="font-size:20px;color:white"  name="icon-xiayi" @click="actionMoveToBack(comp.id)"/> 
                </van-col>
            </van-row>
        </van-list>
    </div>
</template>

<script>
export default {
    components: {},
    props: {
        disabled: false,
        components: null
    },
    data() {
        return {
            clientHeight: 0,
            clientVisable: false
        }
    },
    computed: {
        listHeight() {
            return {
                maxHeight: `${this.clientHeight - 38}px`
            }
        }
    },
    watch:{
        components(val)
        {
            this.resizePanel();
        } ,
    },
    methods: {
        compSelected(id) {
            this.$emit('compSelected', id)
        },
        resizePanel() {
            setTimeout(() => {
                this.clientHeight = document.documentElement.clientHeight/3
            }, 100)
            this.clientVisable = true
            setTimeout(() => {
                this.clientVisable = false
            }, 100)
        },
        onPanelSizeChang(label) {
            if (label === '组件库') {
                this.resizePanel()
            }
        },
        actionRemoveCurrentComp(comp) {
            if (!this.getPermission(comp.permission)) {
                return
            }
            this.compSelected(comp.id);
            this.$emit('actionRemoveCurrentComp');
        },
        actionMoveToFront(id) {
            this.compSelected(id);
            this.$emit('actionMoveToFront');
        },
        actionMoveToBack(id) {
            this.compSelected(id);
            this.$emit('actionMoveToBack');
        },
        getPermission(permission) {
            if (permission) { 
               return this.$checkPermission(permission)   
            } else {
                return true
            }
        },
    },
    mounted() {
        this.resizePanel()
        this.$events.on('PanelCollapseChanged', (label) => {
            this.onPanelSizeChang(label)
        })
        this.$events.on('windowResized', this.resizePanel)
    },
    beforeDestroy() {
        this.$events.off('PanelCollapseChanged')
    }
}
</script>

<style lang="less">
@import "../styles/mixin.less";
.fill-parent-h {
    flex-grow: 1;
}

ul,
li {
    list-style: none;
    margin: 0;
    padding: 0;
}

#complist_panel {
      border-top: 3px solid #666666;
    /*max-height: 460px;*/
    overflow-y: auto;
    @include scrollBar;
}

.page-list {
    background-color: #454545;
    border: 1px solid  #666666;
    border-bottom: none;
    font-size: 20px;
    .page-item {
        height: 40px;
        border-bottom: 1px solid #666666;
        padding: 4px 4px 2px 8px;
    }
    color: white;
}

.isActive {
    background-color: #2d5190;
}

.isHide {
    display: none;
}
</style>
