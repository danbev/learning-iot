#include <stdint.h>
#include <string.h>

#include "nordic_common.h"

#include "nrf.h"
#include "nrf_sdh.h"
#include "nrf_sdh_ble.h"
#include "nrf_ble_gatt.h"
#include "nrf_ble_qwr.h"
#include "nrf_pwr_mgmt.h"
#include "nrf_log.h"
#include "nrf_log_ctrl.h"
#include "nrf_log_default_backends.h"
#include "nrf_drv_gpiote.h"
#include "nrf_gpiote.h"
#include "nrf_gpio.h"
#include "nrf_ble_lesc.h"

#include "app_error.h"

#include "ble.h"
#include "ble_err.h"
#include "ble_hci.h"
#include "ble_srv_common.h"
#include "ble_advdata.h"
#include "ble_conn_params.h"
#include "ble_advertising.h"
#include "ble_lbs.h"

#include "boards.h"
#include "bsp_btn_ble.h"

#include "app_timer.h"
#include "app_button.h"

#include "peer_manager.h"
#include "peer_manager_handler.h"

static void log_error(ret_code_t err);

#define ADVERTISING_LED                 BSP_BOARD_LED_0
#define CONNECTED_LED                   BSP_BOARD_LED_1
#define LEDBUTTON_LED2                  22
#define PERIPHERAL_ADVERTISING_LED      BSP_BOARD_LED_2
#define PERIPHERAL_CONNECTED_LED        BSP_BOARD_LED_3

#define DEVICE_NAME                     "BLE_Ex"

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

/* Perform bonding. */
#define SEC_PARAM_BOND                  1
/* Man In The Middle protection not required. */
#define SEC_PARAM_MITM                  0
/* LE Secure Connections not enabled. */
#define SEC_PARAM_LESC                  1
/* Keypress notifications not enabled. */
#define SEC_PARAM_KEYPRESS              0
/* No I/O capabilities. */
#define SEC_PARAM_IO_CAPABILITIES       BLE_GAP_IO_CAPS_NONE
/* Out Of Band data not available. */
#define SEC_PARAM_OOB                   0
/* Minimum encryption key size. */
#define SEC_PARAM_MIN_KEY_SIZE          7
/* Maximum encryption key size. */
#define SEC_PARAM_MAX_KEY_SIZE          16

//#define LESC_DEBUG_MODE                 1

/* LED Button Service (LBS) instance. */
BLE_LBS_DEF(lbs);

/* GATT module instance. */
NRF_BLE_GATT_DEF(gatt);

/* Context for the Queued Write module. */
NRF_BLE_QWR_DEF(qwr);

/* Advertising module instance. */
BLE_ADVERTISING_DEF(advertising);

/* Handle of the current connection. */
static uint16_t conn_handle = BLE_CONN_HANDLE_INVALID;

static ble_uuid_t adv_uuids[] = {
    {BLE_UUID_DEVICE_INFORMATION_SERVICE, BLE_UUID_TYPE_BLE}
};

#define DEAD_BEEF                           0xDEADBEEF
void assert_nrf_callback(uint16_t line_num, const uint8_t* file_name) {
  app_error_handler(DEAD_BEEF, line_num, file_name);
}

static void leds_init(void) {
  bsp_board_init(BSP_INIT_LEDS | BSP_INIT_BUTTONS);

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

  /* No security required. */
  BLE_GAP_CONN_SEC_MODE_SET_OPEN(&sec_mode);
  /* Encrypted link required. */
  //BLE_GAP_CONN_SEC_MODE_SET_ENC_NO_MITM(&sec_mode);

  err_code = sd_ble_gap_device_name_set(&sec_mode,
                                        (const uint8_t *)DEVICE_NAME,
                                        strlen(DEVICE_NAME));
  APP_ERROR_CHECK(err_code);

  err_code = sd_ble_gap_appearance_set(BLE_APPEARANCE_GENERIC_COMPUTER);
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
  ret_code_t err_code = nrf_ble_gatt_init(&gatt, NULL);
  APP_ERROR_CHECK(err_code);
}

/*
static void advertising_init(void) {
  ret_code_t err_code;
  ble_advdata_t advdata;
  ble_advdata_t srdata;

  ble_uuid_t adv_uuids[] = {{LBS_UUID_SERVICE, lbs.uuid_type}};

  // Build and set advertising data.
  memset(&advdata, 0, sizeof(advdata));
  //advdata.name_type = BLE_ADVDATA_FULL_NAME;
  advdata.name_type = BLE_ADVDATA_SHORT_NAME;
  // Set the length of the short name to be used. This will display the device
  // as 'BLE_P` in nrfConnect.
  advdata.short_name_len = 5;

  // This sets the appearance characteristic which is a 16 bit value that is
  // associated with the device. This can then be used to allow an icon to be
  // displayed for this type of device.
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
  // Allow scan and connect requests from any device. The other options in the
  // enum are to filter scan and/or connect requests using the whitelist.
  adv_params.filter_policy = BLE_GAP_ADV_FP_ANY;
  adv_params.interval = APP_ADV_INTERVAL;
  // Example of restricting advertising to only channel 38.
  adv_params.channel_mask[4] = 0xA0;

  err_code = sd_ble_gap_adv_set_configure(&m_adv_handle, &m_adv_data, &adv_params);
  APP_ERROR_CHECK(err_code);
}
*/

static void sleep_mode_enter(void) {
  ret_code_t err_code;

  err_code = bsp_indication_set(BSP_INDICATE_IDLE);
  APP_ERROR_CHECK(err_code);

  // Prepare wakeup buttons.
  err_code = bsp_btn_ble_sleep_mode_prepare();
  APP_ERROR_CHECK(err_code);

  // Go to system-off mode (this function will not return; wakeup will cause a reset).
  err_code = sd_power_system_off();
  APP_ERROR_CHECK(err_code);
}

static void on_adv_evt(ble_adv_evt_t ble_adv_evt) {
  switch (ble_adv_evt) {
    case BLE_ADV_EVT_FAST:
      bsp_board_led_on(ADVERTISING_LED);
      bsp_board_led_off(CONNECTED_LED);
      break;

    case BLE_ADV_EVT_IDLE:
      {
        ret_code_t err_code = ble_advertising_start(&advertising, BLE_ADV_MODE_FAST);
        APP_ERROR_CHECK(err_code);
        break;
      }

    default:
      break;
  }
}

/*
static void on_adv_evt(ble_adv_evt_t ble_adv_evt) {
  ret_code_t err_code;

  switch (ble_adv_evt) {
    case BLE_ADV_EVT_FAST:
      NRF_LOG_INFO("Fast advertising.");
      err_code = bsp_indication_set(BSP_INDICATE_ADVERTISING);
      APP_ERROR_CHECK(err_code);
      break;

    case BLE_ADV_EVT_IDLE:
      sleep_mode_enter();
      break;

    default:
      break;
  }
}
*/

static void advertising_init(void) {
  ret_code_t err_code;
  ble_advertising_init_t init;

  memset(&init, 0, sizeof(init));

  init.advdata.name_type = BLE_ADVDATA_FULL_NAME;
  init.advdata.include_appearance = true;
  init.advdata.flags = BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE;
  init.advdata.uuids_complete.uuid_cnt = sizeof(adv_uuids) / sizeof(adv_uuids[0]);
  init.advdata.uuids_complete.p_uuids = adv_uuids;

  init.config.ble_adv_fast_enabled = true;
  init.config.ble_adv_fast_interval = APP_ADV_INTERVAL;
  init.config.ble_adv_fast_timeout = APP_ADV_DURATION;

  init.evt_handler = on_adv_evt;
  // Limit the Primary Advertising channel to channel 38.
  advertising.adv_params.channel_mask[4] = 0xA0;

  err_code = ble_advertising_init(&advertising, &init);
  APP_ERROR_CHECK(err_code);

  ble_advertising_conn_cfg_tag_set(&advertising, APP_BLE_CONN_CFG_TAG);
}

static void nrf_qwr_error_handler(uint32_t nrf_error) {
  APP_ERROR_HANDLER(nrf_error);
}

static void led_write_handler(uint16_t conn_handle,
                              ble_lbs_t* lbs, uint8_t led_state) {
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

  err_code = nrf_ble_qwr_init(&qwr, &qwr_init);
  APP_ERROR_CHECK(err_code);

  // Initialize Led Button Service.
  init.led_write_handler = led_write_handler;

  err_code = ble_lbs_init(&lbs, &init);
  APP_ERROR_CHECK(err_code);
}

static void on_conn_params_evt(ble_conn_params_evt_t* evt) {
  ret_code_t err_code;

  if (evt->evt_type == BLE_CONN_PARAMS_EVT_FAILED) {
    err_code = sd_ble_gap_disconnect(conn_handle,
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
  cp_init.disconnect_on_fail = true;
  cp_init.evt_handler = on_conn_params_evt;
  cp_init.error_handler = conn_params_error_handler;

  err_code = ble_conn_params_init(&cp_init);
  APP_ERROR_CHECK(err_code);
}

static void delete_bonds(void) {
  ret_code_t err_code;

  NRF_LOG_INFO("Erase bonds!");
  err_code = pm_peers_delete();
  APP_ERROR_CHECK(err_code);
}

static void advertising_start(bool erase_bonds) {
  NRF_LOG_INFO("advertising_start erase_bonds: %s", (erase_bonds ? "true":"false"));

  if (erase_bonds) {
    delete_bonds();
  } else {
    ret_code_t err_code = ble_advertising_start(&advertising, BLE_ADV_MODE_FAST);
    log_error(err_code);
    APP_ERROR_CHECK(err_code);

    bsp_board_led_on(ADVERTISING_LED);
  }
}

static void ble_evt_handler(ble_evt_t const* ble_evt, void* context) {
  ret_code_t err_code = NRF_SUCCESS;
  NRF_LOG_INFO("ble_evt_handler header.evt_id: %d", ble_evt->header.evt_id);

  nrf_ble_lesc_request_handler();

  switch (ble_evt->header.evt_id) {
    case BLE_GAP_EVT_DISCONNECTED:
      NRF_LOG_INFO("Disconnected.");
      break;

    case BLE_GAP_EVT_CONNECTED:
      NRF_LOG_INFO("Connected.");
      err_code = bsp_indication_set(BSP_INDICATE_CONNECTED);
      APP_ERROR_CHECK(err_code);

      conn_handle = ble_evt->evt.gap_evt.conn_handle;
      err_code = nrf_ble_qwr_conn_handle_assign(&qwr, conn_handle);
      APP_ERROR_CHECK(err_code);

      err_code = pm_conn_secure(ble_evt->evt.gap_evt.conn_handle, false);
      if (err_code != NRF_ERROR_BUSY) {
        APP_ERROR_CHECK(err_code);
      }
      break;

    case BLE_GAP_EVT_PHY_UPDATE_REQUEST:
      NRF_LOG_DEBUG("PHY update request.");
      ble_gap_phys_t const phys = {BLE_GAP_PHY_AUTO, BLE_GAP_PHY_AUTO};
      err_code = sd_ble_gap_phy_update(ble_evt->evt.gap_evt.conn_handle, &phys);
      APP_ERROR_CHECK(err_code);
      break;

      case BLE_GATTC_EVT_TIMEOUT:
        // Disconnect on GATT Client timeout event.
        NRF_LOG_DEBUG("GATT Client Timeout.");
        err_code = sd_ble_gap_disconnect(ble_evt->evt.gattc_evt.conn_handle,
                                         BLE_HCI_REMOTE_USER_TERMINATED_CONNECTION);
        APP_ERROR_CHECK(err_code);
        break;

      case BLE_GATTS_EVT_TIMEOUT:
        // Disconnect on GATT Server timeout event.
        NRF_LOG_DEBUG("GATT Server Timeout.");
        err_code = sd_ble_gap_disconnect(ble_evt->evt.gatts_evt.conn_handle,
                                         BLE_HCI_REMOTE_USER_TERMINATED_CONNECTION);
        APP_ERROR_CHECK(err_code);
        break;

      break;

      default:
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

/*
 * Board Support Package (BSP) event handler.
 */
static void bsp_event_handler(bsp_event_t event) {
  ret_code_t err_code;
  NRF_LOG_INFO("bsp_event_handler...event: %d", event);

  switch (event)
  {
    case BSP_EVENT_SLEEP:
      sleep_mode_enter();
      break; // BSP_EVENT_SLEEP

      case BSP_EVENT_DISCONNECT:
        err_code = sd_ble_gap_disconnect(conn_handle,
                                         BLE_HCI_REMOTE_USER_TERMINATED_CONNECTION);
        if (err_code != NRF_ERROR_INVALID_STATE) {
          APP_ERROR_CHECK(err_code);
        }
        break; // BSP_EVENT_DISCONNECT

      case BSP_EVENT_WHITELIST_OFF:
        if (conn_handle == BLE_CONN_HANDLE_INVALID) {
          err_code = ble_advertising_restart_without_whitelist(&advertising);
          if (err_code != NRF_ERROR_INVALID_STATE) {
            APP_ERROR_CHECK(err_code);
          }
        }
        break; // BSP_EVENT_KEY_0

      default:
        break;
    }
}

static void log_error(ret_code_t err) {
  char const* desc = nrf_strerror_find(err);
  if (desc == NULL) {
    NRF_LOG_ERROR("Function return code: UNKNOWN (%x)", desc);
  } else {
    NRF_LOG_ERROR("Function return code: %s", desc);
  }
}

static void buttons_init(bool* erase_bonds) {
  ret_code_t err_code;
  bsp_event_t startup_event;

  NRF_LOG_INFO("buttons_init");

  err_code = bsp_init(BSP_INIT_LEDS | BSP_INIT_BUTTONS, bsp_event_handler);
  log_error(err_code);
  APP_ERROR_CHECK(err_code);

  err_code = bsp_btn_ble_init(NULL, &startup_event);
  APP_ERROR_CHECK(err_code);

  *erase_bonds = (startup_event == BSP_EVENT_CLEAR_BONDING_DATA);
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
  ret_code_t err_code;
  err_code = nrf_ble_lesc_request_handler();
  APP_ERROR_CHECK(err_code);

  if (NRF_LOG_PROCESS() == false) {
    nrf_pwr_mgmt_run();
  }
}

static void pm_evt_handler(pm_evt_t const* evt) {
  pm_handler_on_pm_evt(evt);
  pm_handler_disconnect_on_sec_failure(evt);
  pm_handler_flash_clean(evt);

  switch (evt->evt_id) {
    case PM_EVT_PEERS_DELETE_SUCCEEDED:
      advertising_start(false);
      break;

    default:
      break;
  }
}

static void peer_manager_init(void) {
  ble_gap_sec_params_t sec_param;
  ret_code_t err_code;

  err_code = pm_init();
  APP_ERROR_CHECK(err_code);

  memset(&sec_param, 0, sizeof(ble_gap_sec_params_t));

  // Security parameters to be used for all security procedures.
  sec_param.bond           = SEC_PARAM_BOND;
  sec_param.mitm           = SEC_PARAM_MITM;
  sec_param.lesc           = SEC_PARAM_LESC;
  sec_param.keypress       = SEC_PARAM_KEYPRESS;
  sec_param.io_caps        = SEC_PARAM_IO_CAPABILITIES;
  sec_param.oob            = SEC_PARAM_OOB;
  sec_param.min_key_size   = SEC_PARAM_MIN_KEY_SIZE;
  sec_param.max_key_size   = SEC_PARAM_MAX_KEY_SIZE;
  sec_param.kdist_own.enc  = 1;
  sec_param.kdist_own.id   = 1;
  sec_param.kdist_peer.enc = 1;
  sec_param.kdist_peer.id  = 1;

  err_code = pm_sec_params_set(&sec_param);
  log_error(err_code);
  APP_ERROR_CHECK(err_code);

  err_code = pm_register(pm_evt_handler);
  APP_ERROR_CHECK(err_code);
}

int main(void) {
  bool erase_bonds;
  ret_code_t err_code;

  NRF_LOG_INFO("BLE_Peripheral example started.");

  uint32_t count = pm_peer_count();
  NRF_LOG_INFO("Number of peers: %d", count);

  log_init();
  leds_init();
  timers_init();
  buttons_init(&erase_bonds);
  power_management_init();
  ble_stack_init();

  gap_params_init();
  gatt_init();

  services_init();
  advertising_init();
  conn_params_init();

  peer_manager_init();
  //db_discovery_init();

  ble_gap_addr_t addr;
  err_code = sd_ble_gap_addr_get(&addr);
  APP_ERROR_CHECK(err_code);
  NRF_LOG_INFO("ADDR: %x:%x:%x:%x:%x:%x\n", addr.addr[5], addr.addr[4],
      addr.addr[3], addr.addr[2], addr.addr[1], addr.addr[0]);

  advertising_start(erase_bonds);

  for (;;) {
    idle_state_handle();
  }
}
