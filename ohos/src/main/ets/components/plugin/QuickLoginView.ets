import MethodChannel, {
  MethodCallHandler,
  MethodResult
} from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import StandardMethodCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMethodCodec';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import { loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { MESSAGES_CHANNEL } from './SignInWithHuaweiPlugin';
import { Any } from '@ohos/flutter_ohos';

@Component
struct ButtonComponent {
  @Prop params: Params
  quickLoginView: QuickLoginView = this.params.platformView as QuickLoginView
  @StorageLink('loading') storageLoading: boolean = true
  @State bkColor: Color = Color.Red
  controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
      .setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
        this.handleLoginWithHuaweiIDButton(error, response);
      })

  handleLoginWithHuaweiIDButton(error: BusinessError | undefined,
    response: loginComponentManager.HuaweiIDCredential) {
    this.quickLoginView.sendMessage(JSON.stringify(response));
  }

  build() {
    Column() {
      LoginWithHuaweiIDButton({
        params: {
          style: loginComponentManager.Style.BUTTON_CUSTOM,
          extraStyle: {
            buttonStyle: new loginComponentManager.ButtonStyle().loadingStyle({
              show: this.storageLoading
            })
          },
          loginType: loginComponentManager.LoginType.QUICK_LOGIN,
        },
        controller: this.controller
      }).id('login_with_huaweiId_button').height(40)
        .width('100%')
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .direction(Direction.Ltr)
    .width('100%')
    .height('100%')
  }
}

@Builder
function ButtonBuilder(params: Params) {
  ButtonComponent({ params: params })
}

AppStorage.setOrCreate('loading', true)

@Observed
export class QuickLoginView extends PlatformView implements MethodCallHandler {
  loading: boolean = true;
  methodChannel: MethodChannel;

  constructor(context: common.Context, viewId: number, args: ESObject, message: BinaryMessenger) {
    super();
    this.methodChannel = new MethodChannel(message, `${MESSAGES_CHANNEL}${viewId}`, StandardMethodCodec.INSTANCE);
    this.methodChannel.setMethodCallHandler(this);
    this.loading = (args as Map<Any, Any>).get('loading');
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    let method: string = call.method;
    let storageLoading: SubscribedAbstractProperty<boolean> = AppStorage.link('loading');
    switch (method) {
      case 'getMessageFromFlutterView':
        const loading: boolean = call.argument("loading");
        this.loading = loading;
        storageLoading.set(loading)
        result.success(true);
        break;
    }
  }

  public sendMessage(message: string) {
    this.methodChannel.invokeMethod('getMessageFromOhosView', message);
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(ButtonBuilder);
  }

  dispose(): void {
  }
}