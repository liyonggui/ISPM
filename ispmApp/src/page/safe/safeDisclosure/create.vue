<style lang="less" scoped type="text/less">
.safeInspection {
  height: 100%;
  background-color: whitesmoke;
  .content {
    overflow: scroll;
    margin-bottom: 50px; // 预留bottom
    .right_delete {
      width: 0.65rem;
      height: 100%;
      font-size: 15px;
      color: #ffffff;
      background: #f44;
    }
  }
}
.content-overlay {
  width: 100%;
  height: 100%;
  box-sizing: border-box;
  //   padding: 10px;
}

.block__title {
  margin: 0;
  font-weight: 400;
  font-size: 14px;
  color: rgba(69, 90, 100, 0.6);
  padding: 5px 10px;
}
</style>

<template>
    <div class="safeInspection c_flex c_direction_v">
        <nav-bar left-arrow :left-text="$t('public.back')" @click-left="toBack" :title="$route.query.id ? $t('safeDisclosure.editTitle') : $t('safeDisclosure.createTitle')"></nav-bar>
        <div class="content c_flex_1" ref="content">

            <van-steps :active="activeStep">
                <van-step>基本信息</van-step>
                <van-step>内容维护</van-step>
                <van-step>添加人员</van-step>
            </van-steps>

            <van-cell-group v-show="activeStep === 0">
                <van-field @blur="formModel.subProjectName=formModel.subProjectName.trim()" input-align="right" v-model="formModel.subProjectName" :label="$t('safeDisclosure.subProjectName')" placeholder="" required />
                <van-cell required :title="$t('safeDisclosure.educationLevel')" :value="$translate({key: 'education_level', value: formModel.educationLevel})" :is-link="true" @click="showEducationLevelList = true" />
                <van-cell required :title="$t('safeDisclosure.disclosureDegree')" :value="$translate({key: 'disclosure_degree', value: formModel.disclosureDegree})" :is-link="true" @click="showDisclosureDegreeList = true" />
            </van-cell-group>

            <div v-show="activeStep === 1">
                <van-cell-group>
                    <van-cell title="安全交底内容" @click="addDisclosureContent()" :value="$t('validationTips.notSelect')" is-link />

                    <van-field @blur="formModel.content=formModel.content.trim()" v-model="formModel.content" type="textarea" placeholder="安全交底内容" :autosize="{ maxHeight: 400, minHeight: 200 }" />
                </van-cell-group>

                <van-cell :title="$t('safeDisclosureContent.industry')" :value="$translate({key: 'industry', value: formModel.safeDisclosureContent.industry})" />
                <van-cell :title="$t('safeDisclosureContent.major')" :value="$translate({key: 'major', value: formModel.safeDisclosureContent.major})" />
                <van-cell :title="$t('safeDisclosureContent.worksType')" :value="$translate({key: 'works_type', value: formModel.safeDisclosureContent.worksType})" />

                <h2 class="block__title">班组信息</h2>
                <van-cell title="班组类型" :value="$translate({key: 'works_type', value: formModel.teamType})" />
                <van-cell title="班组名称" :value="formModel.teamName" />
                <van-cell title="班组编码" :value="formModel.teamCode" />

                <h2 class="block__title">附件列表</h2>
                <van-cell-group>
                    <van-swipe-cell v-for="(item, index) in attachmentList" :key="index" :item-index="index" :right-width="65" :on-close="removeAttachment">
                        <van-cell :title="item.attachment.name">
                        </van-cell>

                        <span class="right_delete c_flex c_a_center c_j_center" slot="right" v-text="$t('public_button.delete')"></span>
                    </van-swipe-cell>
                </van-cell-group>
            </div>

            <div v-show="activeStep === 2">
                <van-cell-group>
                    <van-cell title="安全交底人员" @click="addDisclosureUser()" :value="$t('validationTips.notSelect')" is-link />
                </van-cell-group>

                <h2 class="block__title">人员列表</h2>
                <van-cell-group>
                    <van-swipe-cell v-for="(item, index) in selectionUser" :key="index" :item-index="index" :right-width="65" :on-close="removeDisclosureUser">
                        <van-cell :title="item.user.name">
                        </van-cell>

                        <span class="right_delete c_flex c_a_center c_j_center" slot="right" v-text="$t('public_button.delete')"></span>
                    </van-swipe-cell>
                </van-cell-group>
            </div>

            <van-popup v-model="showEducationLevelList" position="bottom">
                <van-picker value-key="label" show-toolbar :columns="educationLevelList" @confirm="eduLevelConfirmHandler" @cancel="showEducationLevelList = false" />
            </van-popup>
            <van-popup v-model="showDisclosureDegreeList" position="bottom">
                <van-picker value-key="label" show-toolbar :columns="disclosureDegreeList" @confirm="disclosureDegreeHandler" @cancel="showDisclosureDegreeList = false" />
            </van-popup>

            <content-popup v-model="showContentFlag" :works-type="formModel.teamType" @select="contentSelectHandler"></content-popup>
            <user-popup v-model="showUserFlag" @select="userSelectHandler"></user-popup>
        </div>
        <van-submit-bar :button-text="activeStep == 2 ? '完成' : '下一步'" @submit="nextStep"></van-submit-bar>
    </div>
</template>

<script>
import { Toast } from 'vant'
import cloneDeep from 'lodash/cloneDeep'
import uniqBy from 'lodash/uniqBy'

/**安全交底内容 popup */
import contentPopup from './content'
/**安全交底人员 popup */
import userPopup from './user'

const uri = {
    save: '/activiti/safeDisclosure/save',
    update: '/activiti/safeDisclosure/update',
    get: "/activiti/safeDisclosure/get",
    team: '/project/proTeam/list'
};
export default {
    data() {
        return {
            formModel: { safeDisclosureContent: {} },
            currentDate: new Date(),

            showEducationLevelList: false, showDisclosureDegreeList: false,

            /**安全交底内容 */
            showContentFlag: false,
            /**安全交底人员 */
            showUserFlag: false,

            educationLevelList: [{ values: this.$getDictByKey('education_level') }],
            disclosureDegreeList: [{ values: this.$getDictByKey('disclosure_degree') }],

            activeStep: 0,

            /**选中的安全交底内容 */
            selectionContent: [],
            /**安全交底内容附件 */
            attachmentList: [],

            /**选中的安全交底人员 */
            selectionUser: [],

        };
    },
    computed: {
        editFlag() {
            return (!!this.$route.query.id) || this.formModel.id
        }
    },
    components: { contentPopup, userPopup },
    methods: {
        //返回上一页
        toBack(e) {
            if (this.activeStep === 0) {
                this.$router.go(-1)
            } else {
                this.activeStep--
            }
        },

        /**nextStep 下一步 */
        nextStep() {
            if (0 === this.activeStep) {
                /**验证表单输入 */
                let validtorState = true
                if (!this.formModel.subProjectName) {
                    this.$message.error('请输入' + this.$t('safeDisclosure.subProjectName'));
                    validtorState = false
                } else if(!this.formModel.educationLevel){
                    this.$message.error('请输入' + this.$t('safeDisclosure.educationLevel'));
                    validtorState = false
                } else if(!this.formModel.disclosureDegree){
                    this.$message.error('请输入' + this.$t('safeDisclosure.disclosureDegree'));
                    validtorState = false
                }
                if (validtorState) {
                    this.activeStep++
                } else {
                    return
                }
            } else if (1 === this.activeStep) {
                /**提交交底内容 */
                let submitData = cloneDeep(this.formModel)

                this.attachmentList.forEach(item => {
                    item.type = 'disclousure_file_type_1'
                });

                /**编辑操作需要保留现场照片 */
                let imageList = []

                if (this.editFlag) {
                    imageList = this.formModel.safeDisclosureFileList.filter(item => {
                        return item.type === 'disclousure_file_type_2'
                    })
                }
                submitData.safeDisclosureFileList = imageList.concat(this.attachmentList)

                Toast.loading({ mask: true, duration: 0, loadingType: 'spinner' })
                this.$axios.post(this.editFlag ? uri.update : uri.save, submitData)
                    .then(resp => {
                        // TODO: 保存成功后将保存的对象返回，用于人员维护时的提交(DONE)
                        this.formModel = resp
                        this.activeStep++
                    })
                    .finally(() => {
                        Toast.clear()
                    })
            } else if (2 === this.activeStep) {
                /**添加交底人员 */
                let submitData = cloneDeep(this.formModel)
                // submitData.safeDisclosureFileList = this.attachmentList
                submitData.safeDisclosureUserList = this.selectionUser

                Toast.loading({ mask: true, duration: 0, loadingType: 'spinner' })
                this.$axios.post(uri.update, submitData)
                    .then(resp => {

                        this.$router.replace({ name: 'safe_disclosure_info' })
                        // this.activeStep++
                    })
                    .finally(() => {
                        Toast.clear()
                    })

            } else {
                return
            }

        },

        educationLevelChangeHandler(value) {

        },

        /**addDisclosureContent 添加安全交底内容 */
        addDisclosureContent() {
            this.showContentFlag = true
        },

        /**removeDisclosureContent 删除安全交底内容 */
        removeAttachment(clickPosition, instance) {
            switch (clickPosition) {
                case 'left':
                case 'cell':
                case 'outside':
                    instance.close();
                    break;
                case 'right':
                    // this.$dialog.confirm({
                    // message: this.$t('modalTips.deleteModalTips')
                    // }).then(() => {
                    let cellIndex = instance.$attrs['item-index']
                    setTimeout(() => {
                        this.attachmentList.splice(cellIndex, 1)
                        instance.close()
                    }, 100);
                    // })
                    break;
            }
        },

        /**removeDisclosureUser 删除安全交底人员 */
        removeDisclosureUser(clickPosition, instance) {
            switch (clickPosition) {
                case 'left':
                case 'cell':
                case 'outside':
                    instance.close();
                    break;
                case 'right':
                    // this.$dialog.confirm({
                    // message: this.$t('modalTips.deleteModalTips')
                    // }).then(() => {
                    let cellIndex = instance.$attrs['item-index']
                    setTimeout(() => {
                        this.selectionUser.splice(cellIndex, 1)
                        instance.close()
                    }, 100);
                    // })
                    break;
            }
        },

        eduLevelConfirmHandler(value, index) {
            Object.assign(this.formModel, { educationLevel: value[0].value })
            this.showEducationLevelList = false
        },

        disclosureDegreeHandler(value, index) {
            Object.assign(this.formModel, { disclosureDegree: value[0].value })
            this.showDisclosureDegreeList = false
        },


        /**contentSelectHandler 选择安全交底内容 */
        contentSelectHandler(selection) {
            if (selection.attachment) {
                this.attachmentList.splice(0)
                this.attachmentList.push(selection)
            }
            let content = selection.content
            if (content) this.formModel.content = content

            this.formModel.safeDisclosureContent = selection
        },

        /**addDisclosureUser 添加安全交底人员 */
        addDisclosureUser() {
            this.showUserFlag = true
        },

        /**userSelectHandler 选择安全交底人员 */
        userSelectHandler(selection) {
            /**根据 use.id 进行数据去重 */
            this.selectionUser = uniqBy(this.selectionUser.concat(selection), 'user.id')
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

        /**getDetailInfo 编辑操作，获取详细信息 */
        getDetailInfo(id) {
            if (!id) {
                Toast.loading({ mask: true, duration: 0, loadingType: 'spinner' })
                this.$axios
                    .post(uri.team, { teamLeader: { id: this.$store.state.accountInfo.id } })
                    .then(resp => {
                        if (resp.list && resp.list.length > 0) {
                            let teamInfo = resp.list[0]

                            this.formModel.teamType = teamInfo.type
                            this.formModel.teamName = teamInfo.name
                            this.formModel.teamCode = teamInfo.code
                        }
                    })
                    .finally(() => {
                        Toast.clear()
                    })

                return
            }

            Toast.loading({ mask: true, duration: 0, loadingType: 'spinner' })
            this.$axios.post(uri.get, { id: id })
                .then(resp => {
                    if (!resp.safeDisclosureContent) { resp.safeDisclosureContent = {} }
                    this.formModel = resp
                    this.attachmentList = resp.safeDisclosureFileList.filter(item => {
                        return item.type === 'disclousure_file_type_1'
                    })
                    this.selectionUser = resp.safeDisclosureUserList
                })
                .finally(() => {
                    Toast.clear()
                })
        }
    },
    watch: {
        showContentFlag(val) {
            if (!val) this.addEventBackButtonBack()
        },
        showUserFlag(val) {
            if (!val) this.addEventBackButtonBack()
        }
    },

    mounted() {
        this.addEventBackButtonBack();

        let id = this.$route.query.id
        this.$nextTick(() => {
            this.getDetailInfo(id)
        })
    },
};
</script>