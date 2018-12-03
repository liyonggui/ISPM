<template>
<tms-page id="scade_editor">
    <!--头部导航栏-->
    <nav-bar slot="header" class="navbar" ref="head" left-arrow left-text="返回" @click-left="toBack">
        <van-row slot="right" style="width:240px;">
            <van-col span="4" offset="4">
                <van-icon name="icon-baocun" @click="onActionSaveDoc" />
            </van-col>
            <van-col span="4" offset="4">
                <van-icon name="icon-layer" @click="showComplist=!showComplist" />
            </van-col>
            <van-col span="4">
                <van-icon name="icon-fangda" @click="onBackgroundSizeChange(0.1)" />
            </van-col>
            <van-col span="4">
                <van-icon name="icon-suoxiao" @click="onBackgroundSizeChange(-0.1)" />
            </van-col>
        </van-row>
    </nav-bar>
    <div slot="content">
        <!--右侧工具栏-->
        <tools-panel :pointType="pointType" v-show="viewType!='view'" />
        <!--图像编辑区-->
        <v-touch v-on:pinch="onPinch">
            <work-area :style="collapsedLeftStyle" ref="work_area" :draggable="!paramsView" :resizable="!paramsView" :components="components" :canvasConfig="canvasConfig" :isShowBgGrid="canvasConfig.showGrid" @addDropedComp="onAddDropedComp" @addDropedCompSvg="onAddDropedCompSvg" @activated="onActivate" @compLayoutChanged="onDraggerChanged" @input="onDrawPointEnd" @compSelCanceled="unSelCurComp">
            </work-area>
        </v-touch>
        <!--参数界面-->
        <params-panel @callback="onHideParmas" ref="paramCtrl" :showCtrlName="true" :disabled="paramsView" :label.sync="currentLabel"  :compAttrs="currentCtrls" @compValInputChanged="compValInputChanged" @toRectify="toRectify" />

        <!--整改界面-->
        <params-panel ref="rectifyParamCtrl" @callback="onHideParmas" :showCtrlName="false" :compAttrs="currentRectifyCtrls" @compValInputChanged="rectifyValInputChanged">
            <van-row slot="footer">
                <van-col span="12">
                    <van-button size="large" @click="cancelRectify">取消</van-button>
                </van-col>
                <van-col span="12">
                    <van-button size="large" type="primary" @click="saveRectify">发起整改</van-button>
                </van-col>
            </van-row>
        </params-panel>
        <!--组件列表-->
        <van-popup v-model="showComplist" position="bottom" :overlay="false">
            <complist-panel :disabled="viewType=='view'" @actionRemoveCurrentComp="onRemoveCurrentComp" @actionMoveToFront="onMoveToFront" @actionMoveToBack="onMoveToBack" :components="components" @compSelected="onActivate" />
            <van-row>
                <van-col span="24">
                    <van-button size="large" type="primary" @click="showComplist=false">确定</van-button>
                </van-col>
            </van-row>
        </van-popup>
        <!--底部工具栏-->
        <van-row slot="footer" class="foot" v-show="(this.currentCompIndex !== -1)">
            <van-col span="6">
                <div @click="onShowParams">
                    <van-icon name="records" />
                </div>
            </van-col>

            <van-col span="6">
                <van-icon name="icon-zengjia" @click="onSizeChange(1)" />
            </van-col>
            <van-col span="6">
                <!-- <i style="font-size: 36px;color:white;" class="van-icon iconfont icon-jianshao" @click="onSizeChange(-1)">  </i> -->
                <van-icon name="icon-jianshao" @click="onSizeChange(-1)" />
            </van-col>
            <van-col span="6">
                <div @click="onRemoveCurrentComp">
                    <van-icon name="delete" />
                </div>
            </van-col>
        </van-row>
    </div>
</tms-page>
</template>

<script>
import UUID from 'uuid-js'

import cloneDeep from 'lodash/cloneDeep'
import intersection from 'lodash/intersection'
import union from 'lodash/union'
import findIndex from 'lodash/findIndex'

import compParamsConfig from '../components/Scada/config'
import moment from 'moment'
import axios from 'axios'

import ToolsPanel from './toolsPanel.vue'
import WorkArea from './workArea.vue'

import ParamsPanel from './paramsPanel.vue'
import ComplistPanel from './complistPanel.vue'

import config from '../../../config/devconfig'
import scadaComps from '../components/Scada/Basic'
import {
    Toast
} from 'vant'
export default {
    components: {
        ToolsPanel,
        WorkArea,
        ParamsPanel,
        ComplistPanel
    },
    data() {
        return {
            components: [],
            compSymbols: [],
            compSymbolCopy: null,
            curActivedId: -1,
            scadaTemplate: '',
            isCompEditing: false,
            isSvgViewInitiated: false,
            scadaTplStr: null,
            canvasConfig: {
                width: 1000,
                height: 520,
                bgColor: '#FFF',
                showGrid: true,
                zoom: 1
            },
            compLabelState: {},

            railOptions: [],
            selectedRailTypes: [],
            //危险点类型
            dangerousPointTypeOptions: [],
            selectedDangerousPointType: [],
            //危险点状态
            dangerStatusOptions: [],
            selectedDangerStatus: [],
            //围栏状态
            railStatusOptions: [],
            //危险点性质
            pointPropertyOptions: [],

            selectedDangerousProjectType: [],
            selectedProjectStatus: [],
            //设备
            deviceOptions: [],
            viewType: 'view',
            //半径换算
            lengthR: compParamsConfig.lengthR,
            isCollapsed: false,
            paramsStyle: {},
            //危险点，危大工程
            pointType: "",
            //图纸ID
            drawingId: "",
            //参数Zoom
            paramsScale: 'scale(1)',
            collapsedLeftStyle: '',
            //是否显示参数配置
            showParams: false,
            //显示组件列表
            showComplist: false,
            //整改列表
            rectifyList: [],
            //显示整改弹出框
            showRectify: false,

            //整改控件列表
            rectifyParams: [{
                    name: 'seriousLevel',
                    label: '严重程度',
                    type: 'Enum',
                    value: 'serious_level_1',
                    opts: [],
                    required: true
                },
                {
                    name: 'rectifyMan',
                    label: '整改责任人',
                    type: 'Enum',
                    value: '',
                    opts: [],
                    required: true
                },
                {
                    name: 'rectifyDate',
                    label: '整改期限',
                    type: 'DateTime',
                    value: '',
                    required: true
                },
                {
                    name: 'rectifyOpinions',
                    label: '整改意见',
                    type: 'Text',
                    value: '',
                    hint: '输入整改意见',
                    required: true
                }

            ]
        }
    },
    props: {
        propFileId: {
            type: String,
            required: false
        },
        propViewType: {
            type: String,
            required: false
        },
    },
    methods: {

        addComp(compType, name = '', permission, label,
            layout = {
                x: 0,
                y: 0,
                width: 100,
                height: 100,
                ratio: 0
            },
            attrs = [], params = [], innerSvg) {
            const guid = UUID.create(1).toString()
            console.log('guid' + guid);
            const newLabel = this.getCompLabel(label)
            this.onActivate(guid)
            const v = {}
            attrs.forEach((attr) => {
                attr.bind = []
                Object.assign(v, {
                    [attr.name]: attr.value
                })
            })
            const p = {}
            params.forEach((param) => {
                if(param.name =="registerDate")
                {
                    param.value = moment().format('YYYY-MM-DD HH:mm:ss')
                }
                if (param.name == "rail_type" && param.type == "Enum") {
                    param.opts = this.railOptions
                }
                if (param.name == "status" && param.type == "Enum") {
                    if (compType == "sign_type_1" || compType == "sign_type_3") {
                        param.opts = this.dangerStatusOptions
                    } else {
                        param.opts = this.railStatusOptions
                    }
                }
                if (param.name == "drawing_point_type" && param.type == "Enum") {
                    param.opts = this.dangerousPointTypeOptions
                }
                if (param.name == "point_property" && param.type == "Enum") {
                    param.opts = this.pointPropertyOptions
                }
                if (param.name == "deviceId" && param.type == "Enum") {
                    param.opts = this.deviceOptions
                }

                Object.assign(p, {
                    [param.name]: param.value
                })

            })
            let newComp = {
                id: guid,
                name: name,
                permission: permission,
                label: newLabel,
                type: compType,
                active: true,
                layout: layout,
                attrs: attrs,
                value: v,
                show: true,
                paramControls: params,
                params: p,
                bind: {}
            }
            //危险点，危大工程
            if (newComp.type == "sign_type_1" || newComp.type == "sign_type_3") {
                newComp.rectifyParamsControls = this.rectifyParams
                newComp.showRectifyButton = true

            }
            //多边形围栏
            if (newComp.type == "sign_type_2_2") {
                newComp.params.lengthR = this.lengthR
            }
            if (innerSvg) {
                Object.assign(newComp, {
                    innerSvg
                })
                this.components.push(newComp)
            }
            //从接口获取危险点，危大工程编号
            else if (newComp.type == "sign_type_1" || newComp.type == "sign_type_3" || newComp.type.match("sign_type_2") != null) {
                let params = {
                    "drawing": {
                        "id": this.drawingId
                    },
                    "signType": newComp.type.split("_")[0] + "_" + newComp.type.split("_")[1] + "_" + newComp.type.split("_")[2]
                }
                const url = "/safe/safeDrawingPoint/getCode"
                this.$axios.post(url, params).then((response) => {
                        if (response) {
                            newComp.params.code = response
                            this.updateParamControls("code", newComp.params.code, newComp);

                        } else {
                            let msg = "获取编号失败"
                            this.$message.error(msg)
                        }
                        this.components.unshift(newComp)

                    })
                    .catch(err => {
                        console.log('catch')
                        console.log(err)

                    })

            } else {
                this.components.unshift(newComp)
            }
        },
        addSymbol(id, content, url) {
            if (!document.getElementById(id)) {
                this.compSymbols.push({
                    id: id,
                    content: content,
                    url: url
                })
                this.compSymbolCopy = cloneDeep(this.compSymbols)
                this.compSymbolCopy.map(function (item) {
                    item.content = ''
                })
                console.log(this.compSymbolCopy)
            }
        },

        getCompLabel(label) {
            if (this.compLabelState[label]) {
                this.compLabelState[label] += 1
            } else {
                Object.assign(this.compLabelState, {
                    [label]: 1
                })
            }
            return label + `-${this.compLabelState[label]}`
        },
        onAddDropedComp(d) {
            this.$refs.paramCtrl.show = false
            console.log(JSON.stringify(d.type))
            console.log(JSON.stringify(d.name))
            console.log(JSON.stringify(d.config.label))
            this.addComp(d.type, d.name, d.config.permission, d.config.label, d.layout, d.attrs, d.params)
        },
        onAddDropedCompSvg(d) {
            if (d.config.rotatable) {
                d.params.push(Object.assign({}, compParamsConfig.rotateParam))
            }
            if (d.config.colorMask) {
                d.params.push(Object.assign({}, compParamsConfig.colorMaskParam))
            }
            try {
                axios.get(d.config.compSource).then((response) => {
                    this.addSymbol(d.name, response.data, response.config.url)
                    // console.log(response, "res", response.config.url)
                    this.$nextTick(() => {
                        this.addComp('scada-svg-comp', d.name, d.permission, d.config.label, d.layout, [], d.params)
                    })
                })
            } catch (e) {
                console.log(e)
            }
        },
        addStaticSvg(layout = {
            x: 200,
            y: 200,
            width: 300,
            height: 300
        }, svgStr) {
            const params = [Object.assign({}, compParamsConfig.rotateParam)]
            this.addComp('scada-svg', '', d.permission, '导入svg', layout, [], params, svgStr)
        },

        onSettingsChanged(config) {
            this.canvasConfig = Object.assign({}, config)
        },
        onRemoveCurrentComp() {
            if (!this.getPermission(this.components[this.currentCompIndex].permission)) {
                return
            }
            if (this.isCompEditing) {
                //校验业务是否允许删除
                let params = {
                    "id": this.curActivedId,
                }
                const url = "/safe/safeDrawingPoint/check"
                this.$axios.post(url, params).then((response) => {
                        const index = findIndex(this.components, {
                            id: this.curActivedId
                        })
                        if (index >= 0) {
                            if (response) {
                                this.components.splice(index, 1)
                            } else {
                                let msg = "已开展后续业务，不允许删除"
                                this.$message.error(msg)
                            }

                        }

                    })
                    .catch(err => {
                        console.log('catch')
                        console.log(err)

                    })
                    .finally(res => {

                    })

            }
        },
        onDuplicateCurrentComp() {
            const index = findIndex(this.components, {
                id: this.curActivedId
            })
            if (index >= 0) {
                const clonedComp = cloneDeep(this.components[index])
                const layout = clonedComp.layout
                layout.x += 10
                layout.y += 10
                const i = clonedComp.label.lastIndexOf('-')
                const newLabel = (i > -1) ? clonedComp.label.slice(0, i) : clonedComp.label
                this.addComp(clonedComp.type, clonedComp.name, clonedComp.permission, newLabel, layout, clonedComp.attrs, clonedComp.paramControls, clonedComp.innerSvg)
            }
        },
        onMoveToFront() {
            if (this.currentCompIndex !== -1) {
                const c = this.components[this.currentCompIndex]
                this.components.splice(this.currentCompIndex, 1)
                //          this.components.push(c)
                this.components.unshift(c)
            }
        },
        onMoveToBack() {
            if (this.currentCompIndex !== -1) {
                const c = this.components[this.currentCompIndex]
                this.components.splice(this.currentCompIndex, 1)
                //          this.components.unshift(c)
                this.components.push(c)
            }
        },
        onActivate(guid) {
            this.selectBlur()
            this.focusHacking()
            // 同步之前选中组件的数值
            if (this.currentCompIndex !== -1) {
                this.syncCompValues(this.components[this.currentCompIndex])
            }
            this.components.forEach((item) => {
                item.active = (item.id === guid)
            })
            console.log(this.components[this.currentCompIndex])
            this.isCompEditing = true
            this.curActivedId = guid
            if (this.currentCompIndex !== -1) {
                if (this.components[this.currentCompIndex].params.status != "") {
                    this.components[this.currentCompIndex].rectifyParamsControls = this.rectifyParams
                }
            }
        },

        onDraggerChanged(d) {
            this.focusHacking()
            const index = findIndex(this.components, {
                id: d.guid
            })
            if (index !== -1) {

                this.components[index].layout.x = d.x
                this.components[index].layout.y = d.y
                this.components[index].layout.width = d.w
                this.components[index].layout.height = d.h
                if (this.components[index].params.radius) {
                    this.components[index].params.radius = Math.round(d.w / this.lengthR)
                    if( this.components[index].params.radius<1)  this.components[index].params.radius=1
                    this.components[index].params.lengthR = this.lengthR
                    this.updateParamControls("radius", this.components[index].params.radius, this.components[index])
                }

            }

        },
        unSelCurComp() {
            if (this.currentCompIndex !== -1) {
                this.components[this.currentCompIndex].active = false
                this.$refs.paramCtrl.show = false
            }
            this.curActivedId = -1
            this.selectBlur()
        },

        moveCompPos(direction) {
            if (this.currentCompIndex !== -1 && this.components[this.currentCompIndex].type != 'scada-svg') {
                switch (direction) {
                    case 'up':
                        this.components[this.currentCompIndex].layout.y -= 1
                        break
                    case 'down':
                        this.components[this.currentCompIndex].layout.y += 1
                        break
                    case 'left':
                        this.components[this.currentCompIndex].layout.x -= 1
                        break
                    case 'right':
                        this.components[this.currentCompIndex].layout.x += 1
                        break
                }

            }
        },
        // 让焦点放在input上，避免键盘方向键操作滚动条滚动
        focusHacking() {
            // setTimeout(() => {
            //     (document.getElementById('focus-key-hack')).focus()
            // }, 50)
        },
        handleKeyup(e) {
            //        console.log(e.which)
            if (this.currentCompIndex != -1) {
                if (this.components[this.currentCompIndex].type != 'scada-svg') {
                    switch (e.which) {
                        case 37:
                            {
                                this.moveCompPos('left')
                                break
                            }
                        case 39:
                            {
                                this.moveCompPos('right')
                                break
                            }
                        case 38:
                            {
                                this.moveCompPos('up')
                                break
                            }
                        case 40:
                            {
                                this.moveCompPos('down')
                                break
                            }
                        case 8:
                            // case 46:
                            //     {
                            //         this.onRemoveCurrentComp()
                            //         break
                            //     }
                    }
                }
            }
        },
        //鼠标滚轮事件
        // scrollFunc(e) {
        //     let i = e.deltaY > 0 ? -0.1 : 0.1
        //     this.canvasConfig.zoom = this.canvasConfig.zoom + i
        // },
        onActionImportSvg(svgStr) {
            console.log(this.canvasConfig.width);
            console.log(this.canvasConfig.height);
            this.addStaticSvg({
                x: 0,
                y: 0,
                width: this.canvasConfig.width,
                height: this.canvasConfig.height
            }, svgStr)
        },
        onInputFocus(e) {
            if ((e.target.nodeName === 'INPUT') && (e.target.id !== 'focus-key-hack')) {
                this.isCompEditing = false
            }
        },
        onInputBlur() {
            this.isCompEditing = true
        },
        onWindowResized() {
            this.canvasConfig.zoom = Math.floor(document.documentElement.clientHeight / this.canvasConfig.height * 10) / 10
            this.$events.emit('windowResized')
        },
        getDocSaveStr() {
            let componentsStore = [];
            this.components.forEach(element => {
                if (element.type != "scada-svg") {
                    componentsStore.push(element)
                }

            });
            const saveSlot = {
                type: this.pointType,
                drawingId: this.drawingId,
                curActivedId: -1,
                // compSymbols: this.compSymbolCopy,
                componentList: componentsStore,
                // canvasConfig: this.canvasConfig,
                rectifyList: this.rectifyList
            }
            console.log(saveSlot)
            return JSON.stringify(saveSlot)
        },
        loadDocFromTplStr(str) {
            const saveSlot = str
            if (saveSlot) {
                // this.compSymbols = saveSlot.compSymbols || []
                this.$nextTick(() => {
                    this.components = saveSlot.componentList
                    this.curActivedId = saveSlot.curActivedId

                    // this.canvasConfig = saveSlot.canvasConfig
                    //this.canvasConfig.zoom = saveSlot.canvasConfig.zoom
                    //初始化websocket 
                    if (this.viewType == 'view') {
                        this.initWebSocket()
                        this.canvasConfig.showGrid = false
                    }
                })
            }
        },
        onActionOpenLocalDoc() {
            document.getElementById('tpl-uploader').click()
        },
        actionCloseDoc() {
            this.$confirm('是否关闭页面, 是否继续?', '提示', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning'
            }).then(() => {
                window.close();
            }).catch(() => {

            });

        },
        onActionDownDoc() {
            const saveSlot = this.getDocSaveStr()
            const element = document.createElement('a')
            element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(saveSlot))
            element.setAttribute('download', `scada_${moment().format('YYYY-MM-DD_HH-mm-ss')}.tpl`)
            element.style.display = 'none'
            document.body.appendChild(element)
            element.click()
            document.body.removeChild(element)
        },

        syncCompValues(comp) {

            const p = {}
            const v = {}
            const b = {}

            if (comp.paramControls) {
                comp.paramControls.forEach((param) => {
                    Object.assign(p, {
                        [param.name]: param.value
                    })
                })
                comp.params = p
            }
            if (comp.attrs) {
                comp.attrs.forEach((attr) => {
                    if (attr.bind.length > 0) {
                        let bindStr = `${this.bindField}`
                        attr.bind.forEach((f) => {
                            bindStr += `.${f}`
                        })
                        Object.assign(b, {
                            [attr.name]: bindStr
                        })
                    }
                    Object.assign(v, {
                        [attr.name]: attr.value
                    })
                })
                comp.bind = b
                comp.value = v
            }
        },
 
        compValInputChanged(val) {

            if (this.currentCompIndex !== -1) {
                //不允许输入小于1的数字
                if (this.components[this.currentCompIndex].params.radius < 1) {
                    this.components[this.currentCompIndex].params.radius = 1
                }

                let that = this.components[this.currentCompIndex]
                let storeRadius = that.params.radius
                this.syncCompValues(that)
                if (val.name == "radius") {
                    that.layout.width = this.lengthR * that.params.radius;
                    that.layout.height = this.lengthR * that.params.radius;

                    that.layout.x = that.layout.x - (this.lengthR / 2) * (that.params.radius - storeRadius)
                    that.layout.y = that.layout.y - (this.lengthR / 2) * (that.params.radius - storeRadius)
                }
                //切换为待整改状态时显示录入整改信息按钮
                if (val.name == "status" && val.value == "danger_status_2") {
                    this.viewRectifyButton()
                }

            }
        },
        //是否发起过整改（发起过不显示整改按钮）
        viewRectifyButton() {
            if (this.components[this.currentCompIndex].params.status == "danger_status_2") {
                this.components[this.currentCompIndex].rectifyParamsControls = this.rectifyParams
                let params = {
                    "id": this.curActivedId
                }
                const url = "/safe/safeDrawingPoint/checkRectify"
                this.$axios.post(url, params).then((response) => {
                        let curComp = this.components[this.currentCompIndex]
                        if (response) {
                            curComp.showRectifyButton = true

                        } else {
                            curComp.showRectifyButton = false
                        }
                        this.$set(this.components, this.currentCompIndex, curComp)
                    })
                    .catch(err => {
                        console.log('catch')
                        console.log(err)
                    })
            }

        },

        //初始化websocket
        initWebSocket() { //初始化websocket
            const wsuri = config.webSocketURL;
            this.websock = new WebSocket(wsuri); //这里面的this都指向vue
            this.websock.onopen = this.websocketopen;
            this.websock.onmessage = this.websocketonmessage;
            this.websock.onclose = this.websocketclose;
            this.websock.onerror = this.websocketerror;
        },
        websocketopen() { //打开
            console.log("WebSocket连接成功")
        },
        websocketonmessage(e) { //数据接收
            const data = JSON.parse(e.data)
            if (data.topic == "person_safe_monitor") {
                this.createPerson(data.message)
            } else if (data.topic == "drawing_point_refresh") {
                this.onActionOpenDoc(this.drawingId);
            }
            console.log(e)
        },
        websocketclose() { //关闭
            console.log("WebSocket关闭");
        },
        websocketerror() { //失败
            console.log("WebSocket连接失败");
            this.initWebSocket();
        },
        //保存文件
        onActionSaveDoc() {
            Toast.loading({
                mask: true,
                duration: 0,
                message: '保存中...'
            })
            const saveSlot = JSON.parse(this.getDocSaveStr())

            const url = "/safe/safeDrawingPoint/save";
            this.$axios.post(url, saveSlot).then((response) => {
                    Toast.success('保存成功')
                    this.$refs.rectifyParamCtrl.show = false
                    Toast.clear()
                })
                .catch(err => {
                    console.log('catch')
                    console.log(err)
                    Toast.clear()
                })
                .finally(res => {})
        },
        //下载文件
        onActionOpenDoc(id) {
            let param = {
                "drawing": {
                    id: id
                },
                "type": this.pointType
            }

            const url = "/safe/safeDrawingPoint/list"
            this.$axios.post(url, param).then((response) => {
                    if (response.componentList.length > 0) {
                        //重新构造paramControls
                        response.componentList.forEach((comp) => {
                            for (let i = 0; i < scadaComps.tools.length; i++) {
                                let tool = cloneDeep(scadaComps.tools[i])
                                if (comp.type == tool.name) {
                                    comp.paramControls = tool.params
                                    comp.paramControls.forEach((param) => {
                                        if (param.name == "rail_type" && param.type == "Enum") {
                                            param.opts = this.railOptions
                                        }
                                        if (param.name == "status" && param.type == "Enum") {
                                            if (comp.type == "sign_type_1" || comp.type == "sign_type_3") {
                                                param.opts = this.dangerStatusOptions
                                            } else {
                                                param.opts = this.railStatusOptions
                                            }
                                        }
                                        if (param.name == "drawing_point_type" && param.type == "Enum") {
                                            param.opts = this.dangerousPointTypeOptions
                                        }
                                        if (param.name == "point_property" && param.type == "Enum") {
                                            param.opts = this.pointPropertyOptions
                                        }
                                        if (param.name == "deviceId" && param.type == "Enum") {
                                            param.opts = this.deviceOptions
                                        }
                                        let params = comp.params

                                        for (let p in params) {
                                            if (param.name == p) {
                                                param.value = params[p]
                                            }
                                        }
                                        comp.permission = tool.config.permission
                                    })
                                }
                            }
                        })
                        const tplStr = response

                        this.loadDocFromTplStr(tplStr)
                    }

                })
                .catch(err => {
                    console.log('catch')
                    console.log(err)
                })
                .finally(res => {})
        },
        //将控件的params的内容回写到paramControls中
        //@paramsName 参数名称：如point,radius,
        //@parmsValue 参数的值
        //@component 控件
        updateParamControls(paramName, paramValue, component) {
            if (component.paramControls) {
                component.paramControls.forEach((param) => {
                    if (param.name == paramName) {
                        param.value = paramValue
                    }
                })
            }
        },
        //多边形保存点位信息
        onDrawPointEnd(val) {
            if (this.currentCompIndex != -1) {
                if (this.components[this.currentCompIndex].type == "sign_type_2_2") {
                    this.components[this.currentCompIndex].params.point = val.point
                    this.components[this.currentCompIndex].params.viewBox = val.viewBox
                    this.updateParamControls("point", val.point, this.components[this.currentCompIndex])
                    this.updateParamControls("viewBox", val.viewBox, this.components[this.currentCompIndex])
                    console.log("point" + this.components[this.currentCompIndex].params.point);
                    console.log("point" + this.components[this.currentCompIndex].type);
                }
            }
        },
        //围栏选择事件
        onSelectRailTypeChange() {
            //取消当前激活的控件
            if (this.currentCompIndex !== -1) {
                this.components[this.currentCompIndex].active = false
            }
            this.curActivedId = -1
            //获取所有围栏控件guid
            const railGuidList = []
            this.components.forEach(element => {
                if (element.type != "scada-svg") {
                    if (element.type.match("sign_type_2") != null) {
                        railGuidList.push(element.id);
                        element.show = true
                    }
                }
            });
            //获取所有当前选择的围栏控件guid
            const selectedGuidList = []
            this.selectedRailTypes.forEach(element => {
                this.components.forEach(subElement => {
                    if (subElement.type.match("sign_type_2") != null && subElement.params.rail_type == element) {
                        selectedGuidList.push(subElement.id);
                    }
                });
            });
            if (this.selectedRailTypes.length == 0) {
                this.selectedRailTypes = []
            } else {
                //获取所有未选择的围栏控件guid
                var unSelectedGuidList = [];
                for (var i = 0; i < railGuidList.length; i++) {
                    var obj = railGuidList[i];
                    var isExist = false;
                    for (var j = 0; j < selectedGuidList.length; j++) {
                        var aj = selectedGuidList[j];

                        if (aj == obj) {
                            isExist = true;
                            break;
                        }
                    }
                    if (!isExist) {
                        unSelectedGuidList.push(obj);
                        this.hideComp(obj);
                    }
                }
            }
        },
        //危险点选择事件
        onSelectPointChange() {
            //取消当前激活的控件
            if (this.currentCompIndex !== -1) {
                this.components[this.currentCompIndex].active = false
            }
            this.curActivedId = -1
            //获取所有危险点控件guid
            const pointGuidList = []
            this.components.forEach(element => {
                if (element.type == "sign_type_1") {
                    pointGuidList.push(element.id);
                    element.show = true
                }
            });
            //获取所有当前选择的危险点控件guid(类型)
            const selectedGuidListType = []
            this.selectedDangerousPointType.forEach(element => {
                this.components.forEach(subElement => {
                    if (subElement.type == "sign_type_1" && subElement.params.drawing_point_type == element) {
                        selectedGuidListType.push(subElement.id);
                    }
                });
            });

            //获取所有当前选择的危险点控件guid(状态)
            const selectedGuidListStatus = []
            this.selectedDangerStatus.forEach(element => {
                this.components.forEach(subElement => {
                    if (subElement.type == "sign_type_1" && subElement.params.status == element) {
                        selectedGuidListStatus.push(subElement.id);
                    }
                });
            });
            let selectedGuidList = []
            if (this.selectedDangerousPointType.length == 0 || this.selectedDangerStatus.length == 0) {
                selectedGuidList = union(selectedGuidListType, selectedGuidListStatus)
            } else {
                selectedGuidList = intersection(selectedGuidListType, selectedGuidListStatus)
            }
            if (this.selectedDangerousPointType.length == 0 && this.selectedDangerStatus.length == 0) {} else {
                //获取所有未选择的危险点控件guid
                var unSelectedGuidList = [];
                for (var i = 0; i < pointGuidList.length; i++) {
                    var obj = pointGuidList[i];

                    var isExist = false;
                    for (var j = 0; j < selectedGuidList.length; j++) {
                        var aj = selectedGuidList[j];

                        if (aj == obj) {
                            isExist = true;
                            break;
                        }
                    }
                    if (!isExist) {
                        unSelectedGuidList.push(obj);
                        this.hideComp(obj);
                    }

                }
            }
        },

        //危大工程选择事件
        onSelectProjectChange() {
            //取消当前激活的控件
            if (this.currentCompIndex !== -1) {
                this.components[this.currentCompIndex].active = false
            }
            this.curActivedId = -1
            //获取所有危大工程控件guid
            const pointGuidList = []
            this.components.forEach(element => {

                if (element.type == "sign_type_3") {
                    pointGuidList.push(element.id);
                    element.show = true
                }

            });
            //获取所有当前选择的危大工程控件guid(类型)
            let selectedGuidListType = []
            this.selectedDangerousProjectType.forEach(element => {
                this.components.forEach(subElement => {
                    if (subElement.type == "sign_type_3" && subElement.params.drawing_point_type == element) {
                        selectedGuidListType.push(subElement.id);
                    }
                });
            });
            let selectedGuidListStatus = []
            //获取所有当前选择的危大工程控件guid(状态)
            this.selectedProjectStatus.forEach(element => {
                this.components.forEach(subElement => {
                    if (subElement.type == "sign_type_3" && subElement.params.status == element) {
                        selectedGuidListStatus.push(subElement.id);
                    }
                });
            });
            let selectedGuidList = []
            if (this.selectedDangerousProjectType.length == 0 || this.selectedProjectStatus.length == 0) {
                selectedGuidList = union(selectedGuidListType, selectedGuidListStatus)
            } else {
                selectedGuidList = intersection(selectedGuidListType, selectedGuidListStatus)
            }
            if (this.selectedDangerousProjectType.length == 0 && this.selectedProjectStatus.length == 0) {} else {
                //获取所有未选择的危大工程控件guid
                var unSelectedGuidList = [];
                for (var i = 0; i < pointGuidList.length; i++) {
                    var obj = pointGuidList[i];

                    var isExist = false;
                    for (var j = 0; j < selectedGuidList.length; j++) {
                        var aj = selectedGuidList[j];

                        if (aj == obj) {
                            isExist = true;
                            break;
                        }
                    }
                    if (!isExist) {
                        unSelectedGuidList.push(obj);
                        this.hideComp(obj);
                    }

                }
            }
        },

        //根据guid隐藏指定控件
        hideComp(guid) {
            const index = findIndex(this.components, {
                id: guid
            })
            if (index >= 0) {
                this.components[index].show = false
            }

        },
        selectBlur() {
            // this.$refs.railSelect.blur();
            // this.$refs.pointSelect.blur();
            // this.$refs.pointStatusSelect.blur();
            // this.$refs.projectSelect.blur();
            // this.$refs.projectStatusSelect.blur();

            this.$refs.paramCtrl.show = false
            this.$refs.rectifyParamCtrl.show = false
        },
        //创建人员
        createPerson(data) {
            let x, y
            this.components.forEach(element => {
                if (element.type.match("sign_type_2") != null && element.params.deviceId == data.componentId) {
                    let length = Math.round((element.params.radius - 1) * this.lengthR / 2)
                    let offsetX = length + Math.floor(length - (Math.random() * length * 2))
                    let offsetY = length + Math.floor(length - (Math.random() * length * 2))
                    x = element.layout.x + offsetX
                    y = element.layout.y + offsetY

                    const index = this.findPersonIndex(data.userInfo.id)
                    console.log("index" + index)
                    if (index !== -1) {
                        //离开预警范围，删除控件
                        if (data.type == '2') {
                            this.components.splice(index, 1)
                        }
                    } else {
                        const layout = {
                            "x": x,
                            "y": y,
                            "width": 25,
                            "height": 25,
                            "ratio": 0.75
                        }
                        const attrs = [{
                            "name": "val1",
                            "label": "指示值",
                            "type": "Number",
                            "value": 50
                        }]
                        const params2 = [{
                                name: 'id',
                                label: 'ID',
                                type: 'String',
                                value: data.userInfo.id
                            },
                            {
                                name: 'name',
                                label: '姓名',
                                type: 'String',
                                value: data.userInfo.name
                            }
                        ]
                        const d = {
                            name: 'ex-comp-4',
                            config: {

                                label: '员工',
                                compType: 'svg',
                                compSource: require('../../../assets/svg/svg/ex-comp-4.svg'),
                                width: 25,
                                height: 25,
                                keepRatio: true,
                                rotatable: false,
                                colorMask: false

                            },
                            layout: layout,
                            attrs: attrs,
                            params: params2
                        }
                        this.onAddDropedCompSvg(d);
                        this.$message.warning({
                            content: '有人员进入预警区，请注意',
                            top: 50,
                            duration: 3
                        });
                    }
                }

            });

        },

        //移动人员
        movePerson(id, x, y) {
            this.focusHacking()
            const index = this.findPersonIndex(id)
            console.log("index" + index)
            if (index !== -1) {
                this.components[index].layout.x = x
                this.components[index].layout.y = y
            }
        },

        //通过人员id查找人员Index
        findPersonIndex(id) {
            for (let i = 0; i < this.components.length; i++) {
                let element = this.components[i];
                if (element.name == "ex-comp-4" && element.params.id == id) {
                    return i
                }
            }
            return -1
        },
        //收起左侧工具栏
        collapsedLeft(val) {
            this.isCollapsed = val
            if (val) {
                let length = (document.documentElement.clientWidth - this.canvasConfig.width * this.canvasConfig.zoom) / 2

                this.collapsedLeftStyle = "padding-left:" + length + "px"
            } else {
                this.collapsedLeftStyle = ""
            }
            console.log(" this.collapsedLeftStyle " + document.documentElement.clientWidth + ',' + this.canvasConfig.width + ',' + this.collapsedLeftStyle);
        },
        //隐藏参数列表回调
        onHideParmas() {
            this.addEventBackButtonBack()
        },
        //显示参数界面
        onShowParams() {
            this.$refs.paramCtrl.show = true
            this.viewRectifyButton()
        },
        //发起整改
        toRectify() {
            this.$refs.rectifyParamCtrl.show = true
            this.$refs.paramCtrl.show = false
        },
        //修改整改内容
        rectifyValInputChanged(val) {
            if (val.name == "rectifyMan") {
                val.opts.forEach(element => {
                    if (element.value == val.value) {
                        this.components[this.currentCompIndex].rectifyParamsControls.forEach(paramC => {
                            console.log(paramC)
                            if (paramC.name == "office") {
                                paramC.value = element.officeName
                                paramC.officeId = element.officeId
                            }
                        })
                    }
                });
            }

        },

        //保存整改内容
        saveRectify() {
            let p = {}
            let comp = this.components[this.currentCompIndex]
            if (comp.rectifyParamsControls) {
                Object.assign(p, {
                    "drawingPointId": this.curActivedId
                })
                let userInfo = this.$store.state.accountInfo
                let pointRouteParams = JSON.parse(sessionStorage.getItem('pointRouteParams'))
                Object.assign(p, {
                    "checkMan": userInfo.id
                })
                Object.assign(p, {
                    "office": userInfo.company.id
                })
                Object.assign(p, {
                    "reviewMan": userInfo.id
                })
                Object.assign(p, {
                    "region": pointRouteParams.region
                })
                comp.rectifyParamsControls.forEach((param) => {
                    if (param.name == "office") {
                        Object.assign(p, {
                            [param.name]: param.officeId
                        })
                    } else {
                        Object.assign(p, {
                            [param.name]: param.value
                        })
                    }
                })

            }
            let val = true
            if (!p.rectifyMan) {
                let msg = "整改责任人" + "不能为空"
                this.$message.error(msg)
                val = false
            }
            if (!p.rectifyDate) {
                let msg = "整改期限" + "不能为空"
                this.$message.error(msg)
                val = false

            }
            if (!p.rectifyOpinions) {
                let msg = "整改意见" + "不能为空"
                this.$message.error(msg)
                val = false
            }

            if (val) {
                let isContain = false;
                let index
                for (var j = 0; j < this.rectifyList.length; j++) {
                    let com = this.rectifyList[j]
                    if (com.drawingPointId == this.curActivedId) {
                        isContain = true
                        index = i

                        break
                    }
                }
                if (isContain) {
                    this.rectifyList.splice(index, 1)
                }
                this.rectifyList.push(p)
                this.$refs.rectifyParamCtrl.show = false
                this.onActionSaveDoc()
                this.rectifyList = []

            }
        },
        //取消整改内容
        cancelRectify() {
            this.$refs.rectifyParamCtrl.show = false
            this.$refs.paramCtrl.show = true
        },
        //初始化整改信息
        initRectify() {
            const url = "/project/projectUserRole/userList"
            let params = {
                delFlag: "0",
                pageSize: 20
            }
            this.$axios.post(url, params).then((response) => {
                    if (response.list) {
                        let options = []
                        let optionsOffice = []
                        response.list.forEach(element => {
                            //  optionsOffice.push({
                            //     value: element.officeId,
                            //     label: element.officeName
                            // })
                            options.push({
                                value: element.userId,
                                label: element.name,
                                officeId: element.officeId,
                                officeName: element.officeName
                            })
                        });
                        this.rectifyParams.forEach(element => {
                            if (element.name == "checkMan" || element.name == "rectifyMan" || element.name == "reviewMan") {
                                element.opts = options
                            }
                            //  else if(element.name == "office")
                            //  {
                            //      element.opts = optionsOffice
                            //  }
                        });
                        console.log(this.rectifyParams)
                    }

                })
                .catch(err => {
                    console.log('catch')
                    console.log(err)

                })

            this.rectifyParams.forEach(element => {
                if (element.name == "seriousLevel")
                    element.opts = this.$getDictByKey('serious_level')
            });
        },
        getDeviceOptions() {
            const url = "/project/projectEquRegister/list"
            let params = {
                delFlag: "0",
                pageSize: -1,
                type: "equ_type_2"
            }
            this.$axios.post(url, params).then((response) => {
                    if (response.list) {
                        response.list.forEach(element => {
                            this.deviceOptions.push({
                                "label": element.name + '[' + element.uniqueCode + ']',
                                "value": element.id
                            })
                        });
                    }
                })
                .catch(err => {
                    console.log('catch')
                    console.log(err)

                })
        },
        init(fileId, viewType) {
            Toast.loading({
                mask: true,
                message: '加载中...',
                duration: 0
            });
            let _this = this
            let can = document.createElement('canvas');
            let ctx = can.getContext('2d');
            let img = new Image();
            let rotate = 90
            let canWidth, canHeight, drawWidth, drawHeight, height, width
            //固定宽度，必须与web端保持一致
            const clientHeight = 1000

            let url = '/sys/attachment/getFastUrl'
            this.$axios.post(url, {
                    id: fileId
                })
                .then((resp) => {

                    img.src = config.fastURL + resp.fileResponseData.httpUrl
                    img.onload = () => {
                        width = clientHeight / img.height * img.width
                        height = clientHeight

                        let pointRouteParams = sessionStorage.getItem('pointRouteParams')
                        if (pointRouteParams.actualWidth) {
                            console.log(pointRouteParams.actualWidth)
                            if (pointRouteParams.actualWidth == 0) {
                                pointRouteParams.actualWidth = 100
                            }
                            _this.lengthR = Math.round(width / (pointRouteParams.actualWidth) * 1)
                        }

                        canWidth = width;
                        canHeight = height;
                        drawWidth = width;
                        drawHeight = height;
                        can.setAttribute('width', canWidth);
                        can.setAttribute('height', canHeight);

                        ctx.drawImage(img, 0, 0, drawWidth, drawHeight);
                        _this.canvasConfig.bgColor = 'white url(' + can.toDataURL() + ')  0% 0% / contain no-repeat '

                        // this.canvasConfig.height = document.documentElement.clientHeight - 24
                        // this.canvasConfig.width = (document.documentElement.clientHeight - 24) / canHeight * canWidth
                        _this.canvasConfig.width = canWidth;
                        _this.canvasConfig.height = canHeight;

                        _this.canvasConfig.zoom = (clientHeight - 24) / this.canvasConfig.height;
                        _this.railOptions = this.$getDictByKey('rail_type')
                        _this.dangerousPointTypeOptions = this.$getDictByKey('drawing_point_type')
                        _this.dangerStatusOptions = this.$getDictByKey('danger_status')
                        _this.railStatusOptions = this.$getDictByKey('rail_status')
                        _this.pointPropertyOptions = this.$getDictByKey('point_property')
                        _this.getDeviceOptions();
                        console.log(document.documentElement.clientHeight)
                        console.log(document.documentElement.clientWidth)
                        // this.canvasConfig.zoom = Math.floor(document.documentElement.clientHeight / this.canvasConfig.height * 10) / 10
                        // console.log(this.canvasConfig.height + ',' + this.canvasConfig.width + ',' + this.canvasConfig.zoom)
                        // this.canvasConfig.height = this.$refs.work_area.$el.clientHeight;
                        // this.canvasConfig.width = this.$refs.work_area.$el.clientWidth;

                        _this.inCenter()
                        _this.viewType = viewType

                        if (_this.drawingId) {

                            _this.onActionOpenDoc(_this.drawingId)

                        }
                        if (_this.viewType == 'view') {
                            _this.isCollapsed = true
                            _this.unSelCurComp()
                            _this.collapsedLeft(_this.isCollapsed)

                        } else {
                            _this.isCollapsed = false
                            // _this.initRectify()
                        }
                        Toast.clear()
                    }
                })
        },

        onSizeChange(value) {
            let that = this.components[this.currentCompIndex]
            if (!this.getPermission(that.permission)) {
                return
            }

            let storeRadius = that.params.radius
            if (that.params.radius) {
                that.params.radius = that.params.radius + value * 1
                let radius = that.params.radius
                that.layout.width = this.lengthR * radius;
                that.layout.height = this.lengthR * radius;
                that.layout.x = that.layout.x - (this.lengthR / 2) * (radius - storeRadius)
                that.layout.y = that.layout.y - (this.lengthR / 2) * (radius - storeRadius)
            } else {
                that.layout.width = that.layout.width + this.lengthR * value;
                that.layout.height = that.layout.height + this.lengthR * value;
            }

        },
        onBackgroundSizeChange(value) {
            this.canvasConfig.zoom = this.canvasConfig.zoom + value
            this.inCenter()
        },
        //双指缩放
        onPinch(events) {
            console.log("pinch")
            console.log(JSON.stringify(events.scale))
            let scale = 0
            if (events.scale > 1) {
                scale = 0.02
            } else if (events.scale < 1) {
                scale = -0.02
            }
            this.canvasConfig.zoom = this.canvasConfig.zoom + scale
            this.inCenter()
        },
        //画布居中显示  
        inCenter() {
            let length = (document.documentElement.clientWidth - this.canvasConfig.width * this.canvasConfig.zoom) / 2
            length = length < 0 ? 0 : length
            this.collapsedLeftStyle = "padding-left:" + length + "px"
        },
        getPermission(permission) {
            if (permission) {
                return this.$checkPermission(permission)
            } else {
                return true
            }
        },
        //监听返回按钮_按返回键后返回
        addEventBackButtonBack() {
            //监听返回按钮
            if (sessionStorage.plusready === "done") {
                plus.key.removeEventListener("backbutton", () => {
                    plus.runtime.quit();
                });
                plus.key.addEventListener("backbutton", () => {
                    this.toBack();
                });
            }
        },
        toBack() {
            if (this.$refs.rectifyParamCtrl.show) {
                this.$refs.rectifyParamCtrl.show = false
            } else if (this.$refs.paramCtrl.show) {
                this.$refs.paramCtrl.show = false
            } else if (this.showComplist) {
                this.showComplist = false
            } else {
                this.$router.go('-1')
            }
        },

    },
    computed: {
        canvasStyle() {

            return {
                width: this.canvasConfig.width + 'px',
                height: this.canvasConfig.height + 'px',
                background: this.canvasConfig.bgColor,
                transform: `scale(${this.canvasZoom})`
            }
        },
        currentCompIndex() {
            return findIndex(this.components, {
                id: this.curActivedId
            })
        },
        currentLabel: {
            get() {
                if (this.currentCompIndex !== -1) {
                    return this.components[this.currentCompIndex].label
                } else {
                    return ''
                }
            },
            set(val)
            {
                 this.components[this.currentCompIndex].label = val
            }
        },
        currentCtrls: {
            get() {
                if (this.currentCompIndex !== -1) {
                    return this.components[this.currentCompIndex].paramControls
                } else {
                    return []
                }
            }
        },
        currentRectifyCtrls: {
            get() {
                if (this.currentCompIndex !== -1) {
                    return this.components[this.currentCompIndex].rectifyParamsControls
                } else {
                    return []
                }
            }
        },

        isShowCtrlPanel() {
            if (this.currentCompIndex !== -1) {
                if (this.components[this.currentCompIndex].paramControls) {
                    if (this.components[this.currentCompIndex].paramControls.length > 0) {
                        return true
                    }
                }
            }
            return false
        },
        paramsView: {
            get() {
                if (this.viewType == 'view') {
                    return true
                } else if (this.components.length == 0) {
                    return false
                } else if (this.currentCompIndex == -1) {
                    return false
                } else if (this.getPermission(this.components[this.currentCompIndex].permission) == false) {
                    return true
                } else if (this.components[this.currentCompIndex].params) {
                    if ((this.components[this.currentCompIndex].params.auditStatus == 'audit_status_5' || this.components[this.currentCompIndex].params.auditStatus == 'audit_status_2' || this.components[this.currentCompIndex].params.auditStatus == 'audit_status_3')) {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            }
        },
 
    },
    created: function () {},
    mounted() {
        this.addEventBackButtonBack()
        document.documentElement.addEventListener('keyup', this.handleKeyup)
        document.documentElement.addEventListener('focus', this.onInputFocus, true)
        document.documentElement.addEventListener('blur', this.onInputBlur, true)

        window.addEventListener('resize', this.onWindowResized)

        let pointRouteParams = JSON.parse(sessionStorage.getItem('pointRouteParams'))
        this.pointType = pointRouteParams.pointType
        this.drawingId = pointRouteParams.drawingId
        this.init(pointRouteParams.attachmentId, pointRouteParams.viewType);

    },
    beforeMount() {},
    beforeDestroy() {
        window.close()
        Toast.clear()
        document.documentElement.removeEventListener('keyup', this.handleKeyup)
        document.documentElement.removeEventListener('focus', this.onInputFocus, true)
        document.documentElement.removeEventListener('blur', this.onInputBlur, true)
        window.removeEventListener('resize', this.onWindowResized)
        if (this.websock) {
            this.websock.close()
        }
        sessionStorage.removeItem('pointRouteParams')
    },
    watch: {
        propFileId(val) {
            if (val) {
                this.init(val, this.propViewType)
            }
        }
    }
}
</script>

<style lang="less">
@import "../styles/mixin.less";

.filter {
    width: 100%;
    height: 50 px;
    -ms-flex: 0 0 54px;
    flex: 0 0 54px;
    margin: 1px;
    box-shadow: 0 0 3px 1px rgba(0, 0, 0, 0.15);
}

.navbar {
    .van-nav-bar {
        background-color: #454545;
        background-image: unset;
    }
}

.push_menu {
    position: absolute;
    z-index: 1000;
    padding: 5px;
}

.push {
    font-size: 10px;
    border-bottom: 1px solid #535353;
    height: 20px;
    color: #FFF;
    background-color: #424242;

    .push_label {
        padding-left: 165px;
        letter-spacing: 1px;
    }
}

#scade_editor {
    display: flex;
    flex-direction: column;
    height: 100%;
    background-color: #DDD;
    overflow: scroll;

    .van-button--primary {
        color: #fff;
        background-color: #454545;
        border: 1px solid #666666;
    }

    .van-popup--bottom {
        z-index: 3000 !important
    }

    .van-icon {
        font-size: 20px;
        color: white
    }

    .van-cell__right-icon {
        color: #454545;
        font-size: 12px;
        line-height: 24px;
        margin-left: 5px;
    }
}

#bottom_bar {
    width: 100%;
    height: 24px;
    flex: 0 0 24px;
    background-color: #454545;
    border-top: 1px solid #535353;
    padding: 4px 20px 4px 4px;
}

.main {
    width: 100%;
    display: flex;
    flex-grow: 1;
}

#left_panel {
    display: flex;
    width: 210px;
    flex: 0 0 210px;
    flex-direction: column;
    background-color: #454545;
    border: 1px solid #535353;
}

#right_panel {
    width: 320px;
    flex: 0 0 320px;
    background-color: #EEE;
    border: 1px solid #AAA;
    position: absolute;
    z-index: 100;

    .rectifyButton {
        top: 163px;
        right: 7px;
        position: absolute;
    }
}

.foot {
    background-color: #454545;
    color: white;
    width: 100%;
    height: 46px;
    line-height: 46px;
    position: fixed;
    bottom: 0;
    text-align: center;
}

.save {
    width: 50px;
    height: 100%;
    background: url('../../../assets/svg/save.png') no-repeat;
}
</style>
