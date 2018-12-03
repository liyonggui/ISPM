<!--imagePreview-->
<!--@author LiFanLingJue-->
<!--@date 2018/9/4-->
<template>
<div v-if="procInsId">
    <van-cell :title="$t('operation.checklist')" icon="info-o" />
    <van-steps direction="vertical">
        <van-step :key="index" v-for="(item,index) in hisTaskList">
            <p>{{ $t('todoTask.activityName')+':'+item.histIns.activityName}}</p>
            <p v-if="item.assigneeName">{{ $t('todoTask.assigneeName')+':'+ item.assigneeName}}</p>
            <p v-if="item.histIns.startTime">{{$t('todoTask.startTime')+':'+timeFormatter(item.histIns.startTime)}}</p>
            <p v-if="item.histIns.endTime">{{$t('todoTask.endTime')+':'+timeFormatter(item.histIns.endTime)}}</p>
            <p v-if="item.durationTime">{{$t('todoTask.durationTime')+':'+ item.durationTime}}</p>
            <p v-if="item.comment">{{$t('todoTask.comment')+':'+item.comment}}</p>
        </van-step>
    </van-steps>
    <van-loading v-if="!hisTaskListLoaded" style="width: 100%;" />
</div>
</template>

<script>
import moment from 'moment'
export default {
    props: {
        procInsId: {
            type: String
        },
    },
    data() {
        return {
            hisTaskList: [],
            hisTaskListLoaded: true
        }
    },
    methods: {
        //获取审核历史列表
        getTaskHistoicFlow(procInsId) {
            this.hisTaskList = []
            this.hisTaskListLoaded = false
            let params = {
                procInsId: procInsId
            }
            const uri = "/smart-act/act/task/histoicFlow"
            this.$axios.post(uri, params)
                .then(resp => {
                    let tempList = []
                    for (var i = resp.length - 1; i > -1; i--) {
                        tempList.push(resp[i])
                    }

                    this.hisTaskList = Object.assign([], this.hisTaskList, tempList)
                    this.hisTaskListLoaded = true
                })
        },
        timeFormatter(time) {
            return moment(time).format('YYYY-MM-DD HH:mm:ss')
        },
    },
    mounted() {
        this.getTaskHistoicFlow(this.procInsId)
    },
    watch: {
        procInsId(value) {
            if (value) {
                this.getTaskHistoicFlow(value)
            }
        }
    }
}
</script>
