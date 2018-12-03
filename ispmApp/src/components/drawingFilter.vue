<template>
<div class="filterClass">
    <van-tabs v-model="active" :class="show?'tabClassActive':'tabClass'" @click="onClick" swipeable>
        <van-tab>
            <div slot="title">
                <van-icon name="icon-shaixuan" /> {{$t('drawing.region')}}
            </div>
        </van-tab>
        <van-tab :title="$t('drawing.building')"></van-tab>
        <van-tab :title="$t('drawing.subdivision')"></van-tab>
        <van-tab :title="$t('drawing.layer')"></van-tab>
    </van-tabs>
    <div ref="tab" style="position: relative;"> </div>
    <van-popup :lazy-render="false" style="top: unset;" v-model="show" position="top" :overlay="false" :get-container="getContainer">
        <tms-page>
            <div slot="content" style="height:300px">
                <!--区域-->
                <van-checkbox-group v-if="active==0" v-model="regionResult" :max="maxSelect">
                    <!-- <van-checkbox v-for="(dict) in $getBizDictByKey('region')" :key="dict.id" :name="dict">
                        {{dict.name}}
                    </van-checkbox> -->
                    <van-cell-group>
                        <van-cell v-for="(dict,index) in $getBizDictByKey('region')" clickable :key="dict.id" :title="dict.name" @click="toggle(index,'region')">
                            <van-checkbox :name="dict" ref="regionCheckboxes" />
                        </van-cell>
                    </van-cell-group>
                </van-checkbox-group>
                <!--楼宇-->
                <van-checkbox-group v-if="active==1" v-model="buildingResult" :max="maxSelect">
                    <!-- <van-checkbox v-for="(dict) in $getBizDictByKey('building')" :key="dict.id" :name="dict">
                        {{dict.name}}
                    </van-checkbox> -->
                    <van-cell-group>
                        <van-cell v-for="(dict,index) in $getBizDictByKey('building')" clickable :key="dict.id" :title="dict.name" @click="toggle(index,'building')">
                            <van-checkbox :name="dict" ref="buildingCheckboxes" />
                        </van-cell>
                    </van-cell-group>
                </van-checkbox-group>
                <!--分部分项-->
                <van-checkbox-group v-if="active==2" v-model="subdivisionResult" :max="maxSelect">
                    <!-- <van-checkbox v-for="(dict) in $getDictByKey('subdivision')" :key="dict.value" :name="dict">
                        {{dict.label}}
                    </van-checkbox> -->
                    <van-cell-group>
                        <van-cell v-for="(dict,index) in $getDictByKey('subdivision')" clickable :key="dict.value" :title="dict.label" @click="toggle(index,'subdivision')">
                            <van-checkbox :name="dict" ref="subdivisionCheckboxes" />
                        </van-cell>
                    </van-cell-group>
                </van-checkbox-group>
                <!--楼层-->
                <van-checkbox-group v-if="active==3" v-model="layerResult" :max="maxSelect">
                    <!-- <van-checkbox v-for="(dict) in $getBizDictByKey('layer')" :key="dict.id" :name="dict">
                        {{dict.name}}
                    </van-checkbox> -->
                    <van-cell-group>
                        <van-cell v-for="(dict,index) in $getBizDictByKey('layer')" clickable :key="dict.id" :title="dict.name" @click="toggle(index,'layer')">
                            <van-checkbox :name="dict" ref="layerCheckboxes" />
                        </van-cell>
                    </van-cell-group>
                </van-checkbox-group>
            </div>

            <van-row slot="footer">
                <!--重置选择项-->
                <van-col span="12">
                    <van-button size="large" :block="true" @click="reset">{{$t('operation.reset')}}</van-button>
                </van-col>
                <!--确认选择项-->
                <van-col span="12">
                    <van-button size="large" type="danger" :block="true" @click="confirm">{{$t('operation.confirm')}}</van-button>
                </van-col>
            </van-row>
        </tms-page>
    </van-popup>
</div>
</template>

<script>
export default {

    data() {
        return {
            active: 9999,
            regionResult: [],
            buildingResult: [],
            subdivisionResult: [],
            layerResult: [],
            show: false,
            maxSelect: 1
        };
    },
    props: {

    },

    computed: {},
    methods: {
        getContainer() {
            return this.$refs.tab
        },
        onClick() {
            this.show = true
        },
        toggle(index, type) {
            switch (type) {
                case 'region':
                    this.$refs.regionCheckboxes.forEach((element, i) => {
                        if (i == index) {
                            if (element.checked) {
                                this.regionResult = []
                            } else {
                                this.$refs.regionCheckboxes.forEach((subElement, si) => {
                                    if (si != index) {
                                        this.regionResult = []
                                    }
                                });
                                this.regionResult.push(this.$getBizDictByKey('region')[index])
                            }
                        }
                    });
                    break
                case 'building':
                    this.$refs.buildingCheckboxes.forEach((element, i) => {
                        if (i == index) {
                            if (element.checked) {
                                this.buildingResult = []
                            } else {
                                this.$refs.buildingCheckboxes.forEach((subElement, si) => {
                                    if (si != index) {
                                        this.buildingResult = []
                                    }
                                });
                                this.buildingResult.push(this.$getBizDictByKey('building')[index])
                            }
                        }
                    });
                    break
                case 'subdivision':
                    this.$refs.subdivisionCheckboxes.forEach((element, i) => {
                        if (i == index) {
                            if (element.checked) {
                                this.subdivisionResult = []
                            } else {
                                this.$refs.subdivisionCheckboxes.forEach((subElement, si) => {
                                    if (si != index) {
                                        this.subdivisionResult = []
                                    }
                                });
                                this.subdivisionResult.push(this.$getDictByKey('subdivision')[index])
                            }
                        }
                    });
                    break
                case 'layer':
                    this.$refs.layerCheckboxes.forEach((element, i) => {
                        if (i == index) {
                            if (element.checked) {
                                this.layerResult = []
                            } else {
                                this.$refs.layerCheckboxes.forEach((subElement, si) => {
                                    if (si != index) {
                                        this.layerResult = []
                                    }
                                });
                                this.layerResult.push(this.$getBizDictByKey('layer')[index])
                            }
                        }
                    });
                    break
            }
        },
        reset() {
            this.regionResult = []
            this.buildingResult = []
            this.subdivisionResult = []
            this.layerResult = []
        },
        confirm() {
            let result = {}
            result["region"] = this.regionResult.length > 0 ? this.regionResult[0].id : ''
            result["building"] = this.buildingResult.length > 0 ? this.buildingResult[0].id : ''
            result["subdivision"] = this.subdivisionResult.length > 0 ? this.subdivisionResult[0].value : ''
            result["layer"] = this.layerResult.length > 0 ? this.layerResult[0].id : ''
            this.$emit('callback', result)
            this.show = false
        }
    },
    watch: {

    }
};
</script>

<style lang="less">
.filterClass {
    .van-cell {
        background-color: rgb(241, 246, 249);
    }

    .van-popup {
        background-color: rgb(241, 246, 249)
    }

    .tabClass {
        .van-tab--active {
            color: unset;
        }

        .van-tabs__line {
            background-color: unset;
        }

        .van-tab {
            background: rgb(241, 246, 249);
        }

    }

    .tabClassActive {
        .van-tab {
            background: rgb(241, 246, 249);
        }

    }
}
</style>
