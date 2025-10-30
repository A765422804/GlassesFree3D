import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index
{
    build()
    {
        Column()
        {
            List()
            {
                ListItem()
                {
                    Button("ShowImage")
                        .onClick(() =>
                        {
                            this.getUIContext()
                                .getRouter()
                                .pushUrl({ url: "graphics3d/ShowImage" }, router.RouterMode.Single)
                                .catch((error: BusinessError) =>
                                {
                                    console.error(`pushUrl failed, code is ${error.code}, message is ${error.message}`);
                                })
                        })
                        .width('100%')
                }
            }
        }
    }
}