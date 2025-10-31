import { sensor } from '@kit.SensorServiceKit';
import { mat3, vec3, deg2rad } from '../utils/MathUtils'

@Entry
@Component
struct ShowImage
{
    init_rot_mat: mat3 = mat3.I();
    init_rot_x: vec3 = new vec3(1, 0, 0)
    init_rot_y: vec3 = new vec3(0, 1, 0);
    is_orientation_init: boolean = false; // 是否初始化过初始位置
    skip: number = 1; // 跳过 n 帧
    @State image_path: string = ""

    aboutToAppear(): void
    {
        this.Init();
    }

    aboutToDisappear(): void
    {
        sensor.off(sensor.SensorId.ORIENTATION)
    }

    snapOffset_x(v: number): number
    {
        const EPS = 1e-9;
        // 1) 夹紧到 [-30, 30]
        const clamped = Math.max(- 30, Math.min(30, v));
        // 2) 步长 1 的量化：左闭右开，用 floor
        const q = Math.floor(clamped + EPS);
        // 3) 再夹一次，确保返回值在 [-30, 30]
        return Math.max(- 30, Math.min(30, q));
    }

    snapOffset_y(v: number): number
    {
        const EPS = 1e-9;
        // 1) 夹紧到 [-15, 15]
        const clamped = Math.max(- 15, Math.min(15, v));
        // 2) 步长 1 的量化：左闭右开，用 floor
        const q = Math.floor(clamped + EPS);
        // 3) 再夹一次，确保返回值在 [-15, 15]
        return Math.max(- 15, Math.min(15, q));
    }

    Init(): void
    {
        // 初始化方向角度
        sensor.on(sensor.SensorId.ORIENTATION, (data: sensor.OrientationResponse) =>
        {
            if (this.skip > 0)
            {
                this.skip --;
                return;
            }

            if (!this.is_orientation_init)
            {
                this.is_orientation_init = true;

                const init_rot_x = deg2rad(data.beta); // 绕X
                const init_rot_y = deg2rad(data.gamma); // 绕Y
                const init_rot_z = deg2rad(data.alpha); // 绕Z

                const rx = mat3.Rx(init_rot_x);
                const ry = mat3.Ry(init_rot_y);
                const rz = mat3.Rz(init_rot_z);

                this.init_rot_mat = ry.mulMat(rx).mulMat(rz);

                this.init_rot_x = this.init_rot_mat.mulVec(this.init_rot_x).normalize();
                this.init_rot_y = this.init_rot_mat.mulVec(this.init_rot_y).normalize();
            }

            const cur_orientation_x = data.beta;
            const cur_orientation_y = data.gamma;
            const cur_orientation_z = data.alpha;

            const rx = mat3.Rx(deg2rad(cur_orientation_x));
            const ry = mat3.Ry(deg2rad(cur_orientation_y));
            const rz = mat3.Rz(deg2rad(cur_orientation_z));

            const cur_total_rot_mat = ry.mulMat(rx).mulMat(rz);

            const cur_add_rot_mat = cur_total_rot_mat.mulMat(this.init_rot_mat.transpose());

            const axis_angle = cur_add_rot_mat.axisAngle();

            const cur_rot = axis_angle.getRotationAroundAxes(this.init_rot_x, this.init_rot_y)

            // 量化到网格点
            let x: number = this.snapOffset_x(cur_rot[0]);
            let y: number = this.snapOffset_y(cur_rot[1]);

            // 生成图片名（按你的命名：image_a_b）
            this.image_path = `images/image_${y}_${x}.png`;
        }, { interval: 33000000 });

        // 初始化图片
        this.image_path = 'images/image_0_0.png';
    }

    build()
    {
        Column()
        {
            Stack()
            {
                Image(this.image_path)
                // Column({ space: 4 })
                // {
                //     Text("image_path:" + this.image_path)
                //         .fontColor(Color.Black)
                //         .fontSize('12fp')
                //     Text("ori-offset X:" + (this.cur_orientation_x - this.init_orientation_x))
                //         .fontColor(Color.Black)
                //         .fontSize('12fp')
                //     Text("ori-offset Y:" + (this.cur_orientation_y - this.init_orientation_y))
                //         .fontColor(Color.Black)
                //         .fontSize('12fp')
                //     Text("ori-offset Z:" + (this.cur_orientation_z - this.init_orientation_z))
                //         .fontColor(Color.Black)
                //         .fontSize('12fp')
                // }

                // 显示数据
                // Column({ space: 4 })
                // {
                //     Text("orientation X:" + this.cur_orientation_x)
                //         .fontColor(Color.Black)
                //         .fontSize('12fp')
                //     Text("orientation Y:" + this.cur_orientation_y)
                //         .fontColor(Color.Black)
                //         .fontSize('12fp')
                //     Text("orientation Z:" + this.cur_orientation_z)
                //         .fontColor(Color.Black)
                //         .fontSize('12fp')
                // }
                // .padding({
                //     top: "50%"
                // })

                // Column({ space: 4 })
                // {
                //     Text("init_ori X:" + this.init_orientation_x)
                //         .fontColor(Color.Black)
                //         .fontSize('12fp')
                //     Text("init_ori Y:" + this.init_orientation_y)
                //         .fontColor(Color.Black)
                //         .fontSize('12fp')
                //     Text("init_ori Z:" + this.init_orientation_z)
                //         .fontColor(Color.Black)
                //         .fontSize('12fp')
                // }
                // .padding({
                //     top: "50%"
                // })
            }
        }
        .justifyContent(FlexAlign.Center)
    }
}