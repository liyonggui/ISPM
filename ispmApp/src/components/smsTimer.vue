<template>
<div
    class="sendSmsBtn"
    :class="smsDisabled?'dissendSmsBtn':''"
    type="button"
    @click="run"
    :smsDisabled="smsDisabled || time > 0"
>{{ text }}</div>
</template>



<script>
export default {
    props: {
        second: {
            type: Number,
            default: 60
        },
        disabled:{
            type: Boolean,
            default: true
        },
    },
    data: function () {
        return {
            time: 0,
            smsDisabled:true,
        }
    },
    methods: {
        run () {
            if(!this.smsDisabled)
            {
            this.start();
            this.$emit('run');
            }
        },
        start () {
            this.time = this.second;
            this.smsDisabled = true;
            this.timer();
        },


        setDisabled (val) {
            this.smsDisabled = val;
        },
        timer () {
            if (this.time > 0) {
                this.time--;
                setTimeout(this.timer, 1000);
            } else {
                this.smsDisabled = false;
            }
        }

    },
    computed: {
        text: function () {
            return this.time > 0 ? this.time + 's 后重新获取' : '获取';
        }
    },
    watch:
    {
        disabled(curVal,oldVal)
        {
            if(oldVal==true && this.time>0 )
            {
                this.smsDisabled = true;
            }
            else
            {
                this.smsDisabled = curVal;
            }
        }
    },
    mounted() {
        this.smsDisabled = this.disabled;
    }
}
</script>



<style>
.sendSmsBtn {
    color: orangered;
    display: inline-block;
    top: 12px;
}

.sendSmsBtn.dissendSmsBtn {
   color: #888;
}
</style>
