import { Constants } from "../constants/Constants"

import { CalcUtils } from '../utils/CalcUtils';
import Logger from "../utils/Logger"

import {
    Camera,
    Container,
    CubeGeometry,
    Geometry,
    Image,
    Light,
    LightType,
    Material,
    MaterialType,
    Node,
    Scene,
    SceneResourceFactory,
    SceneResourceParameters,
    ShaderMaterial
} from "@kit.ArkGraphics3D";

const TAG = "[SimpleScene]"

@Entry
@Component
struct SimpleScene
{
    scene: Scene | null = null
    @State sceneOpt: SceneOptions | null = null
    @State hierarchy: string = '';
    camera: Camera | null = null
    light: Light | null = null
    // debug mode
    @State debugMode: boolean = false

    onPageShow()
    {
        this.Init();
    }

    traversal(node: Node | null): void
    {
        if (!node)
        {
            return;
        }

        this.hierarchy += node.path + node.name + '\n';
        let container: Container<Node> = node.children;
        let count: number = container.count();

        Logger.info(TAG, `node name: ${node.name}, node path: ${node.path}`)

        this.hierarchy += '  ';
        for (let i = 0; i < count; i ++)
        {
            this.traversal(container.get(i));
        }
    }

    Init()
    {
        if (this.scene == null)
        {
            this.scene = new Scene();
            Scene.load($rawfile("gltf/SimpleScene/glTF/test.glb")).then(async(result: Scene) =>
            {
                this.scene = result;
                let rf: SceneResourceFactory = this.scene.getResourceFactory();

                // camera
                this.camera = await rf.createCamera({ "name": "Camera" });
                this.camera.enabled = true;
                this.camera.position = { x: 0.0, y: 0.0, z: 10.0 }
                this.camera.nearPlane = 0.1;
                this.camera.farPlane = 100.0;

                // light
                // this.light = await rf.createLight({ "name": "Light" }, LightType.DIRECTIONAL);
                // this.light.enabled = true;
                // this.light.color = {
                //     r: 1.0,
                //     g: 1.0,
                //     b: 1.0,
                //     a: 1.0
                // }
                // this.light.intensity = 100.0;
                // CalcUtils.lookAt(this.light, { x: 10.0, y: 10.0, z: 10.0 }, { x: 0.0, y: 0.0, z: 0.0 },
                //     { x: 0.0, y: 1.0, z: 0.0 });

                // hard code
                let plane = this.scene.root?.children.get(0)?.children.get(2);
                if (plane)
                {
                    Logger.info(TAG, `plane name: ${plane.name}`)
                    // 给 plane 添加材质

                    const imgParams: SceneResourceParameters = { name: 'image', uri: $rawfile('texture/catdog.jpg') }
                    const image: Image = await rf.createImage(imgParams)

                    const matParams: SceneResourceParameters = { name: 'material' }
                    const matBase: Material = await rf.createMaterial(matParams, MaterialType.SHADER)
                    const material = matBase as ShaderMaterial

                    if (material.colorShader)
                    {
                        material.colorShader.inputs['BASE_COLOR_Image'] = image;
                    }
                    else
                    {
                        Logger.error(TAG, `material type is not SHADER`)
                    }

                    let geometry = plane as Geometry;
                    geometry.mesh.subMeshes[0].material = material
                }

                this.traversal(this.scene.root)

                this.sceneOpt = { scene: this.scene, modelType: ModelType.SURFACE } as SceneOptions;
            }).catch((err: Error) =>
            {
                Logger.error(TAG, `load scene failed, error name: ${err.name} ,error message: ${err.message}`)
            })
        }
    }

    build()
    {
        Column({ space: Constants.LIST_SPACE })
        {
            Column()
            {
                if (this.sceneOpt)
                {
                    Component3D(this.sceneOpt)
                }
                else
                {
                    Text("Loading...")
                }
            }
            .height(this.debugMode ? Constants.THIRTY_PERCENT : Constants.FULL_PERCENT)
            .width(Constants.FULL_PERCENT)
            .backgroundColor(Color.White)
            .borderRadius($r('app.float.board_radius_normal'))

            if (this.debugMode)
            {
                Column()
                {
                    Text(this.hierarchy)
                        .borderRadius($r('app.float.board_radius_normal'))
                        .fontWeight(FontWeight.Normal)
                }
                .height(Constants.TWENTY_PERCENT)
                .width(Constants.FULL_PERCENT)
                .borderRadius($r('app.float.board_radius_normal'))
                .backgroundColor(Color.White)
                .alignItems(HorizontalAlign.Start)
                .padding($r('app.float.text_area_padding'))
            }

        }
        .width(Constants.FULL_PERCENT)
        .height(Constants.FULL_PERCENT)
    }
}