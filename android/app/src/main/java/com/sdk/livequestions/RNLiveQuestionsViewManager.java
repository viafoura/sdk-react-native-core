package com.sdk.livequestions;

import android.content.Context;
import android.content.res.Resources;
import android.util.DisplayMetrics;
import android.view.Choreographer;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.annotations.ReactPropGroup;
import com.sdk.Utils;
import com.viafourasdk.src.fragments.base.VFFragment;
import com.viafourasdk.src.fragments.livequestions.VFLiveQuestionsFragment;
import com.viafourasdk.src.fragments.livequestions.VFLiveQuestionsFragmentBuilder;
import com.viafourasdk.src.interfaces.VFActionsInterface;
import com.viafourasdk.src.interfaces.VFCustomUIInterface;
import com.viafourasdk.src.interfaces.VFLayoutInterface;
import com.viafourasdk.src.model.local.VFActionData;
import com.viafourasdk.src.model.local.VFActionType;
import com.viafourasdk.src.model.local.VFArticleMetadata;
import com.viafourasdk.src.model.local.VFColors;
import com.viafourasdk.src.model.local.VFCustomViewType;
import com.viafourasdk.src.model.local.VFDefaultColors;
import com.viafourasdk.src.model.local.VFSettings;
import com.viafourasdk.src.model.local.VFTheme;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Map;

public class RNLiveQuestionsViewManager extends ViewGroupManager<RNLiveQuestionsHost> implements VFCustomUIInterface, VFActionsInterface, VFLayoutInterface {

    public static final String REACT_CLASS = "RNLiveQuestionsAndroid";
    public final int COMMAND_CREATE = 1;
    public final int COMMAND_DESTROY = 2;
    ReactApplicationContext reactContext;

    public RNLiveQuestionsViewManager(ReactApplicationContext reactContext) {
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    public RNLiveQuestionsHost createViewInstance(ThemedReactContext reactContext) {
        return new RNLiveQuestionsHost(reactContext);
    }

    @Nullable
    @Override
    public Map<String, Integer> getCommandsMap() {
        return MapBuilder.of("create", COMMAND_CREATE, "destroy", COMMAND_DESTROY);
    }

    @Override
    public void receiveCommand(
            @NonNull RNLiveQuestionsHost root,
            String commandId,
            @Nullable ReadableArray args
    ) {
        super.receiveCommand(root, commandId, args);

        if (args == null || args.size() == 0) {
            return;
        }

        root.reactNativeViewId = args.getInt(0);

        switch (commandId) {
            case "create":
                createFragment(root);
                break;
            case "destroy":
                destroyFragment(root);
                break;
            default: {}
        }
    }

    @Override
    public void onDropViewInstance(@NonNull RNLiveQuestionsHost view) {
        super.onDropViewInstance(view);

        view.stopLayoutCallback();
        destroyFragment(view);
    }

    public void destroyFragment(RNLiveQuestionsHost view) {
        FragmentActivity activity = (FragmentActivity) reactContext.getCurrentActivity();
        if (activity == null) {
            return;
        }

        Fragment fragment = activity.getSupportFragmentManager().findFragmentByTag(String.valueOf(view.reactNativeViewId));

        if(fragment != null){
            activity.getSupportFragmentManager()
                    .beginTransaction()
                    .remove(fragment)
                    .commit();
        }
    }

    @Nullable
    @Override
    public Map getExportedCustomBubblingEventTypeConstants() {
        return MapBuilder.builder()
                .build();
    }

    public void createFragment(RNLiveQuestionsHost root) {
        int reactNativeViewId = root.reactNativeViewId;
        setupLayout(root);

        try {
            VFArticleMetadata articleMetadata = new VFArticleMetadata(new URL(root.articleUrl), root.articleTitle, root.articleDesc, new URL(root.articleThumbnailUrl));
            VFColors colors = new VFColors(VFDefaultColors.getInstance().colorPrimaryDefault(null), VFDefaultColors.getInstance().colorPrimaryLightDefault(null));
            VFSettings settings = new VFSettings(colors);
            FragmentActivity activity = (FragmentActivity) reactContext.getCurrentActivity();

            VFLiveQuestionsFragmentBuilder builder = new VFLiveQuestionsFragmentBuilder(root.containerId, articleMetadata, settings)
                    .actionsInterface(this)
                    .customUIInterface(this);

            if (root.title != null) {
                builder.title(root.title);
            }

            if (root.sectionUUID != null) {
                builder.sectionUUID(root.sectionUUID);
            }

            final VFLiveQuestionsFragment liveQuestionsFragment = builder.build();

            if(activity != null && activity.findViewById(reactNativeViewId) != null) {
                activity.getSupportFragmentManager()
                        .beginTransaction()
                        .replace(reactNativeViewId, liveQuestionsFragment, String.valueOf(reactNativeViewId))
                        .commit();
            }

            liveQuestionsFragment.setLayoutCallback(this);
            liveQuestionsFragment.setTheme(root.darkMode ? VFTheme.dark : VFTheme.light);

        } catch (MalformedURLException | IllegalArgumentException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }
    }

    @ReactPropGroup(names = {"width", "height"}, customType = "Style")
    public void setStyle(RNLiveQuestionsHost view, int index, Integer value) {
        if (index == 1) {
            view.propHeight = value;
        }
    }

    public void setupLayout(final RNLiveQuestionsHost view) {
        view.stopLayoutCallback();

        Choreographer.FrameCallback callback = new Choreographer.FrameCallback() {
            @Override
            public void doFrame(long frameTimeNanos) {
                if (view.layoutCallback != this) {
                    return;
                }

                manuallyLayoutChildren(view);
                view.getViewTreeObserver().dispatchOnGlobalLayout();
                Choreographer.getInstance().postFrameCallback(this);
            }
        };

        view.layoutCallback = callback;
        Choreographer.getInstance().postFrameCallback(callback);
    }

    public static float convertDpToPixel(float dp, Context context){
        return dp * ((float) context.getResources().getDisplayMetrics().densityDpi / DisplayMetrics.DENSITY_DEFAULT);
    }

    public void manuallyLayoutChildren(RNLiveQuestionsHost view) {
        int width = Resources.getSystem().getDisplayMetrics().widthPixels;
        int height = (int) convertDpToPixel(view.propHeight, reactContext);

        view.measure(
                View.MeasureSpec.makeMeasureSpec(width, View.MeasureSpec.EXACTLY),
                View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY));

        view.layout(0, 0, width, height);
    }

    @Override
    public void customizeView(VFTheme theme, VFCustomViewType customViewType, View view) {

    }

    @ReactProp(name = "authorId")
    public void setAuthorId(RNLiveQuestionsHost view, String authorId) {
        view.authorId = authorId;
    }

    @ReactProp(name = "containerId")
    public void setContainerId(RNLiveQuestionsHost view, String containerId) {
        view.containerId = containerId;
    }

    @ReactProp(name = "title")
    public void setTitle(RNLiveQuestionsHost view, String title) {
        view.title = title;
    }

    @ReactProp(name = "sectionUUID")
    public void setSectionUUID(RNLiveQuestionsHost view, String sectionUUID) {
        view.sectionUUID = sectionUUID;
    }

    @ReactProp(name = "articleTitle")
    public void setArticleTitle(RNLiveQuestionsHost view, String articleTitle) {
        view.articleTitle = articleTitle;
    }

    @ReactProp(name = "articleSubtitle")
    public void setArticleSubtitle(RNLiveQuestionsHost view, String articleSubtitle) {
        view.articleDesc = articleSubtitle;
    }

    @ReactProp(name = "articleUrl")
    public void setArticleUrl(RNLiveQuestionsHost view, String articleUrl) {
        view.articleUrl = articleUrl;
    }

    @ReactProp(name = "articleThumbnailUrl")
    public void setArticleThumbnailUrl(RNLiveQuestionsHost view, String articleThumbnailUrl) {
        view.articleThumbnailUrl = articleThumbnailUrl;
    }

    @ReactProp(name = "darkMode")
    public void setDarkMode(RNLiveQuestionsHost view, Boolean darkMode) {
        view.darkMode = darkMode;
    }

    @Override
    public void containerHeightUpdated(VFFragment fragment, String containerId, int height) {
        WritableMap map = Arguments.createMap();
        map.putInt("newHeight", height);
        map.putString("containerId", containerId);
        Utils.sendDataToJS(reactContext, "onHeightChanged", map);
    }

    @Override
    public void onNewAction(VFActionType actionType, VFActionData action) {
        if(actionType == VFActionType.openProfilePressed){
            WritableMap map = Arguments.createMap();
            if(action.getOpenProfileAction().presentationType != null){
                map.putString("presentationType", action.getOpenProfileAction().presentationType.toString());
            }
            map.putString("userUUID", action.getOpenProfileAction().userUUID.toString());
            Utils.sendDataToJS(reactContext, "onOpenProfile", map);
        } else if(actionType == VFActionType.authPressed){
            WritableMap map = Arguments.createMap();
            map.putBoolean("requireLogin", true);
            Utils.sendDataToJS(reactContext, "onAuthNeeded", map);
        }
    }
}
