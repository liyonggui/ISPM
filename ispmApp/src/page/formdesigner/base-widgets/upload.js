/**
 * 上传组件
 */
import config from 'src/config/devconfig'

export default (self, h) => {
    if (!self.data['attachmentUploadWidgetList']) {
        self.$set(self.data, 'attachmentUploadWidgetList', []);
    }
    return [
        h('Upload', {
            ref: 'attachment_upload_widget',
            props: {
                multiple: true,
                type: 'drag',
                action: config.baseURL + '/sys/attachment/fastdfs/upload',
                headers: {
                    token: localStorage.appToken
                },
                'default-file-list': self.data['attachmentUploadWidgetList'],
                'on-remove': (file, fileList) => {
                    file.delFlag = '0';
                    self.$emit('handleChangeVal', file, self);
                },
                'before-upload': () => {
                    self.$refs['attachment_upload_widget'].clearFiles();
                },
                'on-success': (response, file, fileList) => {
                    let uploadFile = {
                        id: response.data.id,
                        name: file.name,
                        delFlag: '1'
                    };
                    self.$emit('handleChangeVal', uploadFile, self);
                },
                'on-error': () => {
                    self.$Message.error(self.$t('message.uploadError'));
                },
                'on-preview': (file) => {
                }
            },
            'class': {
                hideUpload: self.disabled
            },
            style: {
                width: '100%'
            }
        }, [h('div', {
            style: {
                padding: '20px 0'
            }
        }, [h('Icon', {
            props: {
                type: 'ios-cloud-upload',
                size: '52'
            },
            style: {
                color: '#3399ff'
            }
        }), h('p', {
            domProps: {
                innerHTML: self.$t('message.uploadPlaceholder')
            }
        })])])
    ];
};
