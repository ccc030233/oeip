#pragma once

#include "../oeip/Oeip.h"
#include "../oeip-live/OeipLiveRoom.h"
#include "OeipLiveBackCom.h"
#include "../oeip-ffmpeg/FLiveInput.h"
#include "../oeip-ffmpeg/FLiveOutput.h"
#include "../oeip-ffmpeg/FAudioOutput.h"
#include "../oeip-ffmpeg/FMuxing.h"
#include <memory>
#include <vector>

#define LIVE_OUTPUT_MAX 2

struct LiveInput
{
	std::shared_ptr<FLiveInput> In;
	int32_t userId;
	int32_t index;
};

class FFmpegLiveRoom : public OeipLiveRoom
{
public:
	FFmpegLiveRoom();
	virtual ~FFmpegLiveRoom();
private:
	//IOeipLiveClientPtr engine = nullptr;
	//engine这个对象现在实际是C#/COM传递过来的托管对象
	IOeipLiveClient* engine = nullptr;
	OeipLiveBackCom* liveCom = nullptr;
	//推流对象
	//std::vector<std::unique_ptr<FLiveOutput>> liveOuts;
	std::vector<std::unique_ptr<FMuxing>> liveOuts;
	//拉流对象
	std::vector<LiveInput> liveIns;
	std::string mediaServer;
	bool bShutDown = false;
	bool bLogin = false;
	bool bSystemMic = true;
	bool bSystemLoopback = false;

	std::unique_ptr<FAudioOutput> audioOutput = nullptr;
	OeipAudioDesc audioDesc = {};
private:
	void onServerBack(std::string server, int32_t port, int32_t userId);
	void onOperateAction(bool bPush, int32_t index, int32_t operate, int32_t code);
	int32_t findLiveInput(int32_t userId, int32_t index, LiveInput& input);
public:
	void onAudioData(int32_t index, uint8_t* data, int32_t size);
	//拉音频流
	void onAudioFrame(int32_t userId, int32_t index, OeipAudioFrame audioFrame);
	//拉视频流
	void onVideoFrame(int32_t userId, int32_t index, OeipVideoFrame videoFrame);
protected:
	// 通过 OeipLiveRoom 继承
	virtual bool initRoom() override;
	virtual bool loginRoom() override;
	virtual bool pushStream(int32_t index, const OeipPushSetting& setting) override;
	virtual bool stopPushStream(int32_t index) override;
	virtual bool pullStream(int32_t userId, int32_t index) override;
	virtual bool stopPullStream(int32_t userId, int32_t index) override;
	virtual bool logoutRoom() override;
	virtual bool shutdownRoom() override;
	virtual bool pushVideoFrame(int32_t index, const OeipVideoFrame& videoFrame) override;
	virtual bool pushAudioFrame(int32_t index, const OeipAudioFrame& audioFrame) override;
};

OEIP_DEFINE_PLUGIN_CLASS(OeipLiveRoom, FFmpegLiveRoom)

