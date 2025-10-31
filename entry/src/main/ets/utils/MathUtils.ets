export class vec3
{
    x: number
    y: number
    z: number

    constructor(x: number = 0, y: number = 0, z: number = 0)
    {
        this.x = x
        this.y = y
        this.z = z
    }

    /** 向量长度 */
    length(): number
    {
        return Math.hypot(this.x, this.y, this.z)
    }

    /** 就地归一化（修改自身），返回 this */
    normalize(): vec3
    {
        const len = this.length() || 1 // 避免除 0
        this.x /= len
        this.y /= len
        this.z /= len
        return this
    }
}

export class axis_angle
{
    axis: vec3
    angle: number // 弧度
    constructor(axis: vec3, angle: number)
    {
        this.axis = axis
        this.angle = angle
    }

    /**
     * 计算当前轴角旋转绕自定义轴L和D的角度
     * @param axisL 自定义轴L
     * @param axisD 自定义轴D
     * @returns 包含绕L轴和D轴旋转角度的对象
     */
    getRotationAroundAxes(axisL: vec3, axisD: vec3): [angleL: number, angleD: number]
    {
        // 确保输入的轴是单位向量（创建副本避免修改原始向量）
        const l = new vec3(axisL.x, axisL.y, axisL.z).normalize();
        const d = new vec3(axisD.x, axisD.y, axisD.z).normalize();

        // 对D轴进行正交化处理，确保它与L轴垂直
        // 公式：d' = d - (d·l)l
        const dotProduct = l.x * d.x + l.y * d.y + l.z * d.z;
        const dOrthogonal = new vec3(
            d.x - dotProduct * l.x,
            d.y - dotProduct * l.y,
            d.z - dotProduct * l.z
        ).normalize();

        // 计算旋转轴与L轴的点积（投影系数）
        const axisDotL = this.axis.x * l.x + this.axis.y * l.y + this.axis.z * l.z;

        // 计算旋转轴与正交化后的D轴的点积（投影系数）
        const axisDotD = this.axis.x * dOrthogonal.x + this.axis.y * dOrthogonal.y + this.axis.z * dOrthogonal.z;

        // 计算绕L轴和D轴的旋转角度
        const angleL = this.angle * axisDotL;
        const angleD = this.angle * axisDotD;

        return [angleL, angleD];
    }
}

export class mat3
{
    // 行主序 3×3
    private m: number[][];

    constructor(m?: number[][])
    {
        if (m)
        {
            this.m = [
                [m[0][0], m[0][1], m[0][2]],
                [m[1][0], m[1][1], m[1][2]],
                [m[2][0], m[2][1], m[2][2]],
            ];
        }
        else
        {
            // 默认单位阵
            this.m = [[1, 0, 0], [0, 1, 0], [0, 0, 1]];
        }
    }

    /** 设为单位阵（原地修改，返回 this 以便链式调用） */
    identity(): mat3
    {
        this.m = [[1, 0, 0], [0, 1, 0], [0, 0, 1]];
        return this;
    }

    /** 矩阵转置（返回新对象） */
    transpose(): mat3
    {
        const a = this.m;
        return new mat3([
            [a[0][0], a[1][0], a[2][0]],
            [a[0][1], a[1][1], a[2][1]],
            [a[0][2], a[1][2], a[2][2]],
        ]);
    }

    /** 矩阵×矩阵（this * b，返回新对象） */
    mulMat(b: mat3): mat3
    {
        const A = this.m, B = b.m;
        const r: number[][] = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];
        for (let i = 0; i < 3; i ++)
        {
            for (let j = 0; j < 3; j ++)
            {
                r[i][j] = A[i][0] * B[0][j] + A[i][1] * B[1][j] + A[i][2] * B[2][j];
            }
        }
        return new mat3(r);
    }

    /** 矩阵×向量（this * v，返回新 vec3） */
    mulVec(v: vec3): vec3
    {
        const a = this.m
        const x = a[0][0] * v.x + a[0][1] * v.y + a[0][2] * v.z
        const y = a[1][0] * v.x + a[1][1] * v.y + a[1][2] * v.z
        const z = a[2][0] * v.x + a[2][1] * v.y + a[2][2] * v.z
        return new vec3(x, y, z)
    }

    axisAngle(): axis_angle
    {
        const R = this.m
        const m00 = R[0][0], m01 = R[0][1], m02 = R[0][2]
        const m10 = R[1][0], m11 = R[1][1], m12 = R[1][2]
        const m20 = R[2][0], m21 = R[2][1], m22 = R[2][2]

        const trace = m00 + m11 + m22
        const cosTheta = Math.max(- 1, Math.min(1, (trace - 1) * 0.5))
        const angle = Math.acos(cosTheta)

        const EPS = 1e-8
        const PI_EPS = 1e-6

        // 角度极小：近似单位阵
        if (angle < EPS)
        {
            return new axis_angle(new vec3(1, 0, 0), 0.0)
        }

        // 接近 π：用对角分支（更稳定）
        if (Math.abs(Math.PI - angle) < PI_EPS)
        {
            const xx = Math.max(0, (m00 + 1) - (m11 + m22)) * 0.5
            const yy = Math.max(0, (m11 + 1) - (m00 + m22)) * 0.5
            const zz = Math.max(0, (m22 + 1) - (m00 + m11)) * 0.5

            let x = Math.sqrt(xx)
            let y = Math.sqrt(yy)
            let z = Math.sqrt(zz)

            if (x >= y && x >= z)
            {
                y = (m01 + m10) / (4 * (x > EPS ? x : 1))
                z = (m02 + m20) / (4 * (x > EPS ? x : 1))
            }
            else if (y >= x && y >= z)
            {
                x = (m01 + m10) / (4 * (y > EPS ? y : 1))
                z = (m12 + m21) / (4 * (y > EPS ? y : 1))
            }
            else
            {
                x = (m02 + m20) / (4 * (z > EPS ? z : 1))
                y = (m12 + m21) / (4 * (z > EPS ? z : 1))
            }

            const len = Math.hypot(x, y, z) || 1
            return new axis_angle(new vec3(x / len, y / len, z / len), angle)
        }

        // 一般情况
        const denom = 2 * Math.sin(angle)
        let x = (m21 - m12) / denom
        let y = (m02 - m20) / denom
        let z = (m10 - m01) / denom
        const len = Math.hypot(x, y, z) || 1

        return new axis_angle(new vec3(x / len, y / len, z / len), angle)
    }

    // ---------- 静态构造器（角度单位：弧度） ----------

    /** 绕 X 轴旋转 */
    static Rx(a: number): mat3
    {
        const c = Math.cos(a), s = Math.sin(a);
        return new mat3([
            [1, 0, 0],
            [0, c, s],
            [0, - s, c],
        ]);
    }

    /** 绕 Y 轴旋转 */
    static Ry(b: number): mat3
    {
        const c = Math.cos(b), s = Math.sin(b);
        return new mat3([
            [c, 0, - s],
            [0, 1, 0],
            [s, 0, c],
        ]);
    }

    /** 绕 Z 轴旋转 */
    static Rz(ca: number): mat3
    {
        const c = Math.cos(ca), s = Math.sin(ca);
        return new mat3([
            [c, s, 0],
            [- s, c, 0],
            [0, 0, 1],
        ]);
    }

    /** 单位阵 */
    static I(): mat3
    {
        return new mat3();
    }
}

export function deg2rad(deg: number)
{
    return deg * Math.PI / 180;
}