import { sensor } from '@kit.SensorServiceKit';

@Entry
@Component
struct FromEmptyScene
{
    @State cur_gyroscope_x: number = 0;
    @State cur_gyroscope_y: number = 0;
    @State cur_gyroscope_z: number = 0;
    @State image_path: string = ""

    aboutToAppear(): void
    {
        this.Init();
    }

    aboutToDisappear(): void
    {
        sensor.off(sensor.SensorId.GYROSCOPE)
    }

    Init(): void
    {
        // 初始化陀螺仪
        sensor.on(sensor.SensorId.GYROSCOPE, (data: sensor.GyroscopeResponse) =>
        {
            this.cur_gyroscope_x = data.x;
            this.cur_gyroscope_y = data.y;
            this.cur_gyroscope_z = data.z;

            // 切换图片逻辑
            if (this.cur_gyroscope_x > 30)
            {
                this.image_path = 'images/clash_icon_sysproxy.png';
            }
            else
            {
                this.image_path = 'images/clash_icon_tun.png';
            }
        })

        // 初始化图片
        this.image_path = 'images/clash_icon_tun.png';
    }

    build()
    {
        Column({ space: '30' })
        {
            Image(this.image_path)
                .width("50%")
                .aspectRatio(1)
                .border({ width: 2, color: Color.Gray })
                .borderRadius('50%')
                .clip(true)

            Column()
            {
                Text("Gyroscope X: " + this.cur_gyroscope_x)
                Text("Gyroscope Y: " + this.cur_gyroscope_y)
                Text("Gyroscope Z: " + this.cur_gyroscope_z)
            }
            .width('100%')

            // 仅仅用于测试
            Button("Text")
                .onClick(() =>
                {
                    if (this.image_path == 'images/clash_icon_tun.png')
                    {
                        this.image_path = 'images/clash_icon_sysproxy.png';
                    }
                    else
                    {
                        this.image_path = 'images/clash_icon_tun.png';
                    }
                })

        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
    }
}