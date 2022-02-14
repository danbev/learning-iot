#include <stdint.h>
#include <string.h>
#include "nordic_common.h"
#include "nrf.h"
#include "app_error.h"
#include "ble.h"
#include "ble_err.h"
#include "ble_hci.h"
#include "ble_srv_common.h"
#include "ble_advdata.h"
#include "ble_conn_params.h"
#include "nrf_sdh.h"
#include "nrf_sdh_ble.h"
#include "boards.h"
#include "app_timer.h"
#include "app_button.h"
#include "ble_lbs.h"
#include "nrf_ble_gatt.h"
#include "nrf_ble_qwr.h"
#include "nrf_pwr_mgmt.h"
#include "peer_manager.h"

#include "nrf_log.h"
#include "nrf_log_ctrl.h"
#include "nrf_log_default_backends.h"

#include "nrf_drv_gpiote.h"
#include "nrf_gpiote.h"
#include "nrf_gpio.h"

#define ADVERTISING_LED                 BSP_BOARD_LED_0
#define CONNECTED_LED                   BSP_BOARD_LED_1
#define LEDBUTTON_LED                   BSP_BOARD_LED_2
#define LEDBUTTON_LED2                  22
#define LEDBUTTON_BUTTON                BSP_BUTTON_0

#define DEVICE_NAME                     "BLE_Peripheral_Example"

#define APP_BLE_OBSERVER_PRIO           3
/* A tag identifying the SoftDevice BLE configuration */
#define APP_BLE_CONN_CFG_TAG            1
/* The advertising interval (in units of 0.625 ms; this value corresponds to
   0.625*1600 = 1000 ms). */
#define APP_ADV_INTERVAL                1600
/* The advertising time-out (in units of seconds). When set to 0, we will never
   time out. */
#define APP_ADV_DURATION                BLE_GAP_ADV_TIMEOUT_GENERAL_UNLIMITED
/* Minimum acceptable connection interval (0.5 seconds). */
#define MIN_CONN_INTERVAL               MSEC_TO_UNITS(100, UNIT_1_25_MS)
/* Maximum acceptable connection interval (1 second). */
#define MAX_CONN_INTERVAL               MSEC_TO_UNITS(200, UNIT_1_25_MS)
/* Slave latency. */
#define SLAVE_LATENCY                   0
/* Connection supervisory time-out (4 seconds). */
#define CONN_SUP_TIMEOUT                MSEC_TO_UNITS(4000, UNIT_10_MS)

/* Time from initiating event (connect or start of notification) to first time
   sd_ble_gap_conn_param_update is called (15 seconds). */
#define FIRST_CONN_PARAMS_UPDATE_DELAY  APP_TIMER_TICKS(20000)
/* Time between each call to sd_ble_gap_conn_param_update after the first call
  (5 seconds). */
#define NEXT_CONN_PARAMS_UPDATE_DELAY   APP_TIMER_TICKS(5000)
/* Number of attempts before giving up the connection parameter negotiation. */
#define MAX_CONN_PARAMS_UPDATE_COUNT    3

/* Delay from a GPIOTE event until a button is reported as pushed (in number
   of timer ticks). */
#define BUTTON_DETECTION_DELAY          APP_TIMER_TICKS(50)
/* Value used as error code on stack dump, can be used to identify stack
   location on stack unwind. */
#define DEAD_BEEF                       0xDEADBEEF

/* LED Button Service (LBS) instance. */
BLE_LBS_DEF(m_lbs);

/* GATT module instance. */
NRF_BLE_GATT_DEF(m_gatt);

/* Context for the Queued Write module. */
NRF_BLE_QWR_DEF(m_qwr);

/* Handle of the current connection. */
static uint16_t m_conn_handle = BLE_CONN_HANDLE_INVALID;
/* Advertising handle used to identify an advertising set. */
static uint8_t m_adv_handle = BLE_GAP_ADV_SET_HANDLE_NOT_SET;
/* Buffer for storing an encoded advertising set. */
static uint8_t m_enc_advdata[BLE_GAP_ADV_SET_DATA_SIZE_MAX];
/* Buffer for storing an encoded scan data. */
static uint8_t m_enc_scan_response_data[BLE_GAP_ADV_SET_DATA_SIZE_MAX];

/* Struct that contains pointers to the encoded advertising data. */
static ble_gap_adv_data_t m_adv_data = {
  .adv_data = { m_enc_advdata, BLE_GAP_ADV_SET_DATA_SIZE_MAX },
  .scan_rsp_data = { m_enc_scan_response_data,BLE_GAP_ADV_SET_DATA_SIZE_MAX }
};

static void leds_init(void) {
  bsp_board_init(BSP_INIT_LEDS);
  nrf_gpio_cfg_output(LEDBUTTON_LED2);
}

static void timers_init(void) {
  ret_code_t err_code = app_timer_init();
  APP_ERROR_CHECK(err_code);
}

static void gap_params_init(void) {
  ret_code_t err_code;
  ble_gap_conn_params_t gap_conn_params;
  ble_gap_conn_sec_mode_t sec_mode;

  BLE_GAP_CONN_SEC_MODE_SET_OPEN(&sec_mode);

  err_code = sd_ble_gap_device_name_set(&sec_mode,
                                        (const uint8_t *)DEVICE_NAME,
                                        strlen(DEVICE_NAME));
  APP_ERROR_CHECK(err_code);

  memset(&gap_conn_params, 0, sizeof(gap_conn_params));
  gap_conn_params.min_conn_interval = MIN_CONN_INTERVAL;
  gap_conn_params.max_conn_interval = MAX_CONN_INTERVAL;
  gap_conn_params.slave_latency = SLAVE_LATENCY;
  gap_conn_params.conn_sup_timeout = CONN_SUP_TIMEOUT;

  err_code = sd_ble_gap_ppcp_set(&gap_conn_params);
  APP_ERROR_CHECK(err_code);
}

static void gatt_init(void) {
  ret_code_t err_code = nrf_ble_gatt_init(&m_gatt, NULL);
  APP_ERROR_CHECK(err_code);
}

static void advertising_init(void) {
  ret_code_t err_code;
  ble_advdata_t advdata;
  ble_advdata_t srdata;

  ble_uuid_t adv_uuids[] = {{LBS_UUID_SERVICE, m_lbs.uuid_type}};

  // Build and set advertising data.
  memset(&advdata, 0, sizeof(advdata));
  //advdata.name_type = BLE_ADVDATA_FULL_NAME;
  advdata.name_type = BLE_ADVDATA_SHORT_NAME;
  /* Set the length of the short name to be used. This will display the device
   * as 'BLE_P` in nrfConnect */
  advdata.short_name_len = 5;

  /* 
   * This sets the appearance characteristic which is a 16 bit value that is
   * associated with the device. This can then be used to allow an icon to be
   * displayed for this type of device.
   */
  err_code = sd_ble_gap_appearance_set(BLE_APPEARANCE_GENERIC_COMPUTER);
  APP_ERROR_CHECK(err_code);

  uint16_t appearance;
  err_code = sd_ble_gap_appearance_get(&appearance);
  APP_ERROR_CHECK(err_code);
  NRF_LOG_INFO("appearance: %d\n", appearance);

  advdata.include_appearance = true;
  advdata.flags = BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE;

  memset(&srdata, 0, sizeof(srdata));
  srdata.uuids_complete.uuid_cnt = sizeof(adv_uuids) / sizeof(adv_uuids[0]);
  srdata.uuids_complete.p_uuids = adv_uuids;

  err_code = ble_advdata_encode(&advdata, m_adv_data.adv_data.p_data,
                                &m_adv_data.adv_data.len);
  APP_ERROR_CHECK(err_code);
  NRF_LOG_INFO("Encoded Advertisement data %#010x\n", m_adv_data.adv_data.p_data);

  err_code = ble_advdata_encode(&srdata, m_adv_data.scan_rsp_data.p_data,
                                &m_adv_data.scan_rsp_data.len);
  APP_ERROR_CHECK(err_code);

  ble_gap_adv_params_t adv_params;

  // Set advertising parameters.
  memset(&adv_params, 0, sizeof(adv_params));

  adv_params.primary_phy = BLE_GAP_PHY_1MBPS;
  adv_params.duration = APP_ADV_DURATION;
  adv_params.properties.type = BLE_GAP_ADV_TYPE_CONNECTABLE_SCANNABLE_UNDIRECTED;
  adv_params.p_peer_addr = NULL;
  /* Allow scan and connect requests from any device. The other options in the
   * enum are to filter scan and/or connect requests using the whitelist */
  adv_params.filter_policy = BLE_GAP_ADV_FP_ANY;
  adv_params.interval = APP_ADV_INTERVAL;
  /* Example of restricting advertising to only channel 38 */
  adv_params.channel_mask[4] = 0xA0;

  err_code = sd_ble_gap_adv_set_configure(&m_adv_handle, &m_adv_data, &adv_params);
  APP_ERROR_CHECK(err_code);
}

static void nrf_qwr_error_handler(uint32_t nrf_error) {
  APP_ERROR_HANDLER(nrf_error);
}

static void led_write_handler(uint16_t conn_handle,
                              ble_lbs_t * p_lbs, uint8_t led_state) {
  if (led_state) {
    nrf_gpio_pin_set(LEDBUTTON_LED2);
    NRF_LOG_INFO("Received LED ON!");
  } else {
    nrf_gpio_pin_clear(LEDBUTTON_LED2);
    NRF_LOG_INFO("Received LED OFF!");
  }
}

static void services_init(void) {
  ret_code_t err_code;
  // Led Button Service init
  ble_lbs_init_t init = {0};
  nrf_ble_qwr_init_t qwr_init = {0};

  // Initialize Queued Write Module.
  qwr_init.error_handler = nrf_qwr_error_handler;

  err_code = nrf_ble_qwr_init(&m_qwr, &qwr_init);
  APP_ERROR_CHECK(err_code);

  // Initialize Led Button Service.
  init.led_write_handler = led_write_handler;

  err_code = ble_lbs_init(&m_lbs, &init);
  APP_ERROR_CHECK(err_code);
}

static void on_conn_params_evt(ble_conn_params_evt_t * p_evt) {
  ret_code_t err_code;

  if (p_evt->evt_type == BLE_CONN_PARAMS_EVT_FAILED) {
    err_code = sd_ble_gap_disconnect(m_conn_handle,
                                     BLE_HCI_CONN_INTERVAL_UNACCEPTABLE);
    APP_ERROR_CHECK(err_code);
  }
}

static void conn_params_error_handler(uint32_t nrf_error) {
  APP_ERROR_HANDLER(nrf_error);
}

static void conn_params_init(void) {
  ret_code_t err_code;
  ble_conn_params_init_t cp_init;

  memset(&cp_init, 0, sizeof(cp_init));
  cp_init.p_conn_params = NULL;
  cp_init.first_conn_params_update_delay = FIRST_CONN_PARAMS_UPDATE_DELAY;
  cp_init.next_conn_params_update_delay = NEXT_CONN_PARAMS_UPDATE_DELAY;
  cp_init.max_conn_params_update_count = MAX_CONN_PARAMS_UPDATE_COUNT;
  cp_init.start_on_notify_cccd_handle = BLE_GATT_HANDLE_INVALID;
  cp_init.disconnect_on_fail = false;
  cp_init.evt_handler = on_conn_params_evt;
  cp_init.error_handler = conn_params_error_handler;

  err_code = ble_conn_params_init(&cp_init);
  APP_ERROR_CHECK(err_code);
}

static void advertising_start(void) {
  ret_code_t err_code;
  err_code = sd_ble_gap_adv_start(m_adv_handle, APP_BLE_CONN_CFG_TAG);
  APP_ERROR_CHECK(err_code);

  bsp_board_led_on(ADVERTISING_LED);
}

static void ble_evt_handler(ble_evt_t const * p_ble_evt, void * p_context) {
  ret_code_t err_code;
  NRF_LOG_INFO("ble_evt_handler header.evt_id: %d", p_ble_evt->header.evt_id);

  switch (p_ble_evt->header.evt_id) {
    case BLE_GAP_EVT_CONNECTED:
      NRF_LOG_INFO("Connected");
      bsp_board_led_on(CONNECTED_LED);
      bsp_board_led_off(ADVERTISING_LED);

      m_conn_handle = p_ble_evt->evt.gap_evt.conn_handle;
      err_code = nrf_ble_qwr_conn_handle_assign(&m_qwr, m_conn_handle);
      APP_ERROR_CHECK(err_code);
      err_code = app_button_enable();
      APP_ERROR_CHECK(err_code);
      break;
    case BLE_GAP_EVT_DISCONNECTED:
      NRF_LOG_INFO("Disconnected");
      bsp_board_led_off(CONNECTED_LED);
      m_conn_handle = BLE_CONN_HANDLE_INVALID;

      err_code = app_button_disable();
      APP_ERROR_CHECK(err_code);
      advertising_start();
      break;
    case BLE_GAP_EVT_SEC_PARAMS_REQUEST:
      // Pairing not supported
      err_code = sd_ble_gap_sec_params_reply(m_conn_handle,
                                             BLE_GAP_SEC_STATUS_PAIRING_NOT_SUPP,
                                             NULL,
                                             NULL);
      APP_ERROR_CHECK(err_code);
      break;
    case BLE_GAP_EVT_PHY_UPDATE_REQUEST:
      {
        NRF_LOG_DEBUG("PHY update request.");
        ble_gap_phys_t const phys = { BLE_GAP_PHY_AUTO, BLE_GAP_PHY_AUTO };
        err_code = sd_ble_gap_phy_update(p_ble_evt->evt.gap_evt.conn_handle, &phys);
        APP_ERROR_CHECK(err_code);
      }
      break;
    case BLE_GATTS_EVT_SYS_ATTR_MISSING:
      // No system attributes have been stored.
      err_code = sd_ble_gatts_sys_attr_set(m_conn_handle, NULL, 0, 0);
      APP_ERROR_CHECK(err_code);
      break;
    case BLE_GATTC_EVT_TIMEOUT:
      // Disconnect on GATT Client timeout event.
      NRF_LOG_DEBUG("GATT Client Timeout.");
      err_code = sd_ble_gap_disconnect(p_ble_evt->evt.gattc_evt.conn_handle,
                                       BLE_HCI_REMOTE_USER_TERMINATED_CONNECTION);
      APP_ERROR_CHECK(err_code);
      break;
    case BLE_GATTS_EVT_TIMEOUT:
      // Disconnect on GATT Server timeout event.
      NRF_LOG_DEBUG("GATT Server Timeout.");
      err_code = sd_ble_gap_disconnect(p_ble_evt->evt.gatts_evt.conn_handle,
                                       BLE_HCI_REMOTE_USER_TERMINATED_CONNECTION);
      APP_ERROR_CHECK(err_code);
      break;
    default:
      // No implementation needed.
      break;
    }
}

static void ble_stack_init(void) {
  ret_code_t err_code;

  err_code = nrf_sdh_enable_request();
  APP_ERROR_CHECK(err_code);

  // Configure the BLE stack using the default settings.
  // Fetch the start address of the application RAM.
  uint32_t ram_start;
  err_code = nrf_sdh_ble_default_cfg_set(APP_BLE_CONN_CFG_TAG, &ram_start);
  APP_ERROR_CHECK(err_code);

  // Enable BLE stack.
  err_code = nrf_sdh_ble_enable(&ram_start);
  APP_ERROR_CHECK(err_code);

  // Register a handler for BLE events.
  NRF_SDH_BLE_OBSERVER(m_ble_observer, APP_BLE_OBSERVER_PRIO, ble_evt_handler, NULL);
}

static void button_event_handler(uint8_t pin_no, uint8_t button_action) {
  ret_code_t err_code;

  static uint8_t counter = 0;

  switch (pin_no) {
    case LEDBUTTON_BUTTON:
      NRF_LOG_INFO("Send button state change. action: %d", button_action);
      if (button_action == 1) {
        counter++;
      }
      err_code = ble_lbs_on_button_change(m_conn_handle, &m_lbs, counter);
      if (err_code != NRF_SUCCESS &&
        err_code != BLE_ERROR_INVALID_CONN_HANDLE &&
        err_code != NRF_ERROR_INVALID_STATE &&
        err_code != BLE_ERROR_GATTS_SYS_ATTR_MISSING) {
        APP_ERROR_CHECK(err_code);
      }
      break;
    default:
      APP_ERROR_HANDLER(pin_no);
      break;
  }
}

static void buttons_init(void) {
  ret_code_t err_code;

  //The array must be static because a pointer to it will be saved in the button handler module.
  static app_button_cfg_t buttons[] = {
      {LEDBUTTON_BUTTON, false, BUTTON_PULL, button_event_handler}
  };

  err_code = app_button_init(buttons, ARRAY_SIZE(buttons),
                             BUTTON_DETECTION_DELAY);
  APP_ERROR_CHECK(err_code);
}

static void log_init(void) {
  ret_code_t err_code = NRF_LOG_INIT(NULL);
  APP_ERROR_CHECK(err_code);

  NRF_LOG_DEFAULT_BACKENDS_INIT();
}

static void power_management_init(void) {
  ret_code_t err_code;
  err_code = nrf_pwr_mgmt_init();
  APP_ERROR_CHECK(err_code);
}

static void idle_state_handle(void) {
  if (NRF_LOG_PROCESS() == false) {
    nrf_pwr_mgmt_run();
  }
}

int main(void) {
  NRF_LOG_INFO("BLE_Peripheral example started.");

  ret_code_t err_code;
  uint32_t count = pm_peer_count();
  NRF_LOG_INFO("Number of peers: %d", count);

  log_init();
  leds_init();
  timers_init();
  buttons_init();
  power_management_init();
  ble_stack_init();
  gap_params_init();
  gatt_init();
  services_init();
  advertising_init();
  conn_params_init();

  ble_gap_addr_t addr;
  err_code = sd_ble_gap_addr_get(&addr);
  APP_ERROR_CHECK(err_code);
  NRF_LOG_INFO("ADDR: %x:%x:%x:%x:%x:%x\n", addr.addr[5], addr.addr[4],
      addr.addr[3], addr.addr[2], addr.addr[1], addr.addr[0]);

  advertising_start();

  for (;;) {
    idle_state_handle();
  }
}
