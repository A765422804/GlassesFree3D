import { UIContext, NodeController, FrameNode, RenderNode, DrawContext } from '@kit.ArkUI';
import { drawing } from '@kit.ArkGraphics2D';

// 1. 自定义RenderNode
export class MyRenderNode extends RenderNode
{
    async draw(context: DrawContext)
    {
        const canvas = context.canvas;
        // 3. 自定义的绘制相关操作
        const brush = new drawing.Brush();
        brush.setColor({
            red: 255,
            blue: 0,
            green: 0,
            alpha: 255
        });
        canvas.attachBrush(brush);
        canvas.drawRect({
            left: 0,
            right: 300,
            top: 0,
            bottom: 300
        });
    }
}

// 2. 自定义NodeController
export class MyNodeController extends NodeController
{
    private rootNode: FrameNode | null = null;
    myRenderNode = new MyRenderNode();

    makeNode(uiContext: UIContext): FrameNode
    {
        this.rootNode = new FrameNode(uiContext);
        if (this.rootNode === null)
        {
            return this.rootNode;
        }

        const renderNode = this.rootNode.getRenderNode();
        if (renderNode !== null)
        {
            this.myRenderNode.backgroundColor = 0xffffffff;
            this.myRenderNode.frame = {
                x: 0,
                y: 0,
                width: 4800,
                height: 4800
            };
            this.myRenderNode.pivot = { x: 0.2, y: 0.8 };
            this.myRenderNode.scale = { x: 1, y: 1 };
            renderNode.appendChild(this.myRenderNode);
            renderNode.clipToFrame = true;
        }
        return this.rootNode;
    }
}

@Entry
@Component
struct RenderTest
{
    @State message: string = 'hello'

    build()
    {
        Row()
        {
            Column()
            {
                // 4. 将自定义NodeController进行显示
                NodeContainer(new MyNodeController())
                    .width('100%')
            }
            .width('100%')
            .height('80%')
        }
        .height('100%')
    }
}