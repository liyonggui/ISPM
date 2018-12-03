<!--imagePreview-->
<!--@author LiFanLingJue-->
<!--@date 2018/9/4-->
<template>
    <div class="img-con c_flex" v-if="imagesArr.length">
        <div class="img-item" v-for="(item, index) in imagesArr" @click="showPreviewImage(item, index)"
             :key="index">
            <img :src="item.src" style="width: 100%; height: 100%;" alt="" srcset="">
        </div>
    </div>
</template>
<script>
    import config from 'src/config/devconfig'
    import {ImagePreview} from 'vant'

    export default {
        props: {
            data: {type: Array, default: () => []},
        },
        data() {
            return {
                imagesArr: [],
                imgPreInstance: {}
            }
        },
        methods: {
            showPreviewImage(item, idx) {
                if (this.imagesEditMode) {
                    this.$set(item, '__checked', !item.__checked);
                } else {
                    this.imgPreInstance = ImagePreview({
                        images: this.imagesArr.map(item => {
                            return item.detailSrc
                        }),
                        startPosition: idx
                    })
                    
                }
            },
          
        },
        watch: {
            data(val) {
                if (val.length) {
                    if (!this.$store.state.offLine) {
                        this.imagesArr = [];
                        let attachments = val.map(item => {
                            return {id: item}
                        });
                        this.$axios.post('/sys/attachment/urlList', attachments)
                            .then(resp => {
                                resp.forEach(item => {
                                    this.imagesArr.push(
                                        {
                                            id: item.id,
                                            src: config.fastURL + item.fileResponseData.httpPreviewUrl,
                                            detailSrc: config.fastURL + item.fileResponseData.httpUrl,
                                            info: item.name
                                        }
                                    )
                                })
                            })
                    }
                } else {
                    this.imagesArr = []
                }
            }
        }
    }
</script>
<style type="text/less" lang="less" scoped>
    .img-con {
        padding: 5px;
        flex-wrap: wrap;
        background: #fff;
        .img-item {
            position: relative;
            margin: 1%;
            width: 31.3%;
            height: 100px;
            border: 1px dotted #999;
            border-radius: 5px;
        }
    }
</style>
