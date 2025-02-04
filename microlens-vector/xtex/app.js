const sleep = (delay) => new Promise((resolve) => setTimeout(resolve, delay));

function sliceText(text, maxLength) {
	// better slice()
	if (maxLength == 0) { // disabled
		return text;
	} else if (text.length <= maxLength) { // shorter than maxLength
		return text;
	}
	return text.slice(0, maxLength) + '...';
}

let firstLoad = true;

async function update() {
	let refresh_time = 5000;
	// let url = 'https://xtex.envs.net/lens/l.cgi?/sleepy/query';
	let url = 'https://lens.xtexx.eu.org/l/sleepy/query';
	while (true) {
		if (document.visibilityState == 'visible' || firstLoad) {
			console.log('tab visible, updating...');
			firstLoad = false;
			let success_flag = true;
			let errorinfo = '';
			const statusElement = document.getElementById('status');
			// show updating
			const updatingElement = document.getElementById('updating-message');
			updatingElement.className = 'updating';
			// fetch data
			fetch(url, { timeout: 10000 })
				.then(response => response.json())
				.then(async (data) => {
					console.log(data);
					if (data.success) {
						// update status (status, additional-info)
						statusElement.textContent = data.info.name;
						document.getElementById('additional-info').innerHTML = data.info.desc;
						statusElement.className = 'status-' + data.info.color;

						// update device status (device-status)
						var deviceStatus = '<h2>设备状态</h2>';
						const devices = Object.values(data.device);
						for (let device of devices) {
							console.log(device);

							// 决定设备状态显示
							if (device.using) {
								// replace "xxx" with 'xxx'
								var device_app_title = device.app_name.replace('"', '\\"').replace('\'', '\\\'');
								var device_show_name = device.show_name.replace('"', '\\"').replace('\'', '\\\'');
								var device_app_alert = device.app_name.replace('"', '\\"').replace('\'', '\\\'');
								// build
								var device_app = `<a class="device-status-using" style="font-size: 18px;" title="${device_app_title}" href="javascript:alert('${device_show_name}: ${device_app_alert}')">${sliceText(device.app_name, data.device_status_slice)}</a>`;
							} else {
								var device_app = '<a class="device-status-unused" style="font-size: 18px;" >未在使用</a>';
							}
							deviceStatus += `<div class="setting-card"> <div class="left"><h3>${device.show_name}</h3></div><div class="right">${device_app}</div> </div>`;  // 设备卡片（设备名称+设备状态）
						}
						if (deviceStatus == '<h2>设备状态</h2>') {
							deviceStatus = '';
						}

						document.getElementById('device-status').innerHTML = deviceStatus;
						// update last update time (last-updated)
						document.getElementById('last-updated').textContent = `最后更新：${data.last_updated}`;
						// update refresh time
						refresh_time = data.refresh;

						updatingElement.className = '';
					} else {
						errorinfo = data.info;
						success_flag = false;
					}
				})
				.catch(error => {
					errorinfo = error;
					success_flag = false;
				});
			// update error
			if (!success_flag) {
				statusElement.textContent = '[!错误!]';
				document.getElementById('additional-info').textContent = errorinfo;
				statusElement.className = 'status-error';
			}
		} else {
			console.log('tab not visible, skip update');
		}

		await sleep(refresh_time);
	}
}

update();
