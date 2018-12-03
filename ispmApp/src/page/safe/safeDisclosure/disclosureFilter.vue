<template>
    <div class="filterClass">
        <van-tabs v-model="active" :class="show?'tabClassActive':'tabClass'" @click="onClick" swipeable>
            <van-tab>
                <div slot="title">
                    <van-icon name="icon-shaixuan" /> 分类
                </div>
            </van-tab>
        </van-tabs>
        <div ref="tab" style="position: relative;"> </div>
        <van-popup :lazy-render="false" style="top: unset;" v-model="show" position="top" :overlay="false" :get-container="getContainer">
            <tms-page>
                <div slot="content" style="height:300px">
                    <van-checkbox-group v-if="active==0" v-model="typeResult" :max="maxSelect">
                        <van-cell-group>
                            <van-cell v-for="(dict,index) in $getDictByKey('works_type')" clickable :key="dict.value" :title="dict.label" @click="toggle(index)">
                                <van-checkbox :name="dict" ref="typeCheckboxes" />
                            </van-cell>
                        </van-cell-group>
                    </van-checkbox-group>
                </div>
                <van-row slot="footer">
                    <van-col span="12">
                        <van-button size="large" :block="true" @click="reset">{{$t('operation.reset')}}</van-button>
                    </van-col>
                    <van-col span="12">
                        <van-button size="large" type="danger" :block="true" @click="confirm">{{$t('operation.confirm')}}</van-button>
                    </van-col>
                </van-row>
            </tms-page>
        </van-popup>
    </div>
</template>

<script>
import clickoutside from '../../../utils/click-outside'
export default {
    directives: { clickoutside },
    data() {
        return {
            active: 9999,
            typeResult: [],
            show: false,
            maxSelect: 1
        };
    },
    props: {
        defaultFilter: {
            type: Object, default: () => { return {} }
        }
    },
    watch: {
        show(val) {
            if (val) {
                this.$refs.typeCheckboxes.forEach((element, i) => {
                    if (element.name.value === this.defaultFilter.type) {
                        if (element.checked) return
                        this.$refs.typeCheckboxes[i].toggle()
                    }
                });
            } else {
                let result = {}
                result.type = this.typeResult.length > 0 ? this.typeResult[0].value : ''
                this.$emit('callback', result)
            }
        }
    },
    computed: {},
    methods: {
        getContainer() {
            return this.$refs.tab
        },
        onClick() {
            this.show = true
        },
        toggle(index) {
            this.$refs.typeCheckboxes.forEach((element, i) => {
                if (i == index) {
                    element.toggle();
                } else {
                    if (element.checked) {
                        element.toggle();
                    }
                }
            });
        },
        reset() {
            this.typeResult = []
        },
        confirm() {
            this.show = false
        }
    },
};
</script>

<style lang="less">
.filterClass {
  .van-cell {
    background-color: rgb(241, 246, 249);
  }

  .van-popup {
    background-color: rgb(241, 246, 249);
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
