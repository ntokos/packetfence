<template>
  <base-form
    :form="form"
    :meta="meta"
    :schema="schema"
    :isLoading="isLoading"
  >
    <form-group-identifier namespace="id"
                           :column-label="$i18n.t('Name')"
                           :disabled="!isNew && !isClone"
    />

    <form-group-description namespace="description"
                            :column-label="$i18n.t('Description')"
    />

    <form-group-api-url namespace="api_url"
                        :column-label="$i18n.t('API URL')"
    />

    <form-group-service-id namespace="service_id"
                     :column-label="$i18n.t('Service ID')"
    />

    <form-group-message-id namespace="message_id"
                     :column-label="$i18n.t('Message ID')"
    />

    <form-group-institution namespace="institution"
                     :column-label="$i18n.t('Institution')"
    />

    <form-group-preshared-key namespace="preshared_key"
                     :column-label="$i18n.t('Pre-shared Key')"
    />

    <form-group-message namespace="message"
                     :column-label="$i18n.t('SMS text message')"
                     :text="$i18n.t('Replacements value ($pin)')"
    />

    <form-group-pin-code-length namespace="pin_code_length"
                                :column-label="$i18n.t('PIN length')"
                                :text="$i18n.t('The amount of digits of the PIN number.')"
    />

    <form-group-create-local-account namespace="create_local_account"
                                     :column-label="$i18n.t('Create Local Account')"
                                     :text="$i18n.t('Create a local account on the PacketFence system based on the username provided.')"
                                     enabled-value="yes"
                                     disabled-value="no"
    />

    <form-group-hash-passwords namespace="hash_passwords"
                               :column-label="$i18n.t('Database passwords hashing method')"
                               :text="$i18n.t('The algorithm used to hash the passwords in the database.This will only affect newly created or reset passwords.')"
    />

    <form-group-password-length namespace="password_length"
                                :column-label="$i18n.t('Password length')"
                                :text="$i18n.t('The length of the password to generate.')"
    />

    <form-group-local-account-logins namespace="local_account_logins"
                                     :column-label="$i18n.t('Amount of logins for the local account')"
                                     :text="$i18n.t('The amount of times, the local account can be used after its created. 0 means infinite.')"
    />

    <form-group-local-account-expiration namespace="local_account_expiration"
                                         :column-label="$i18n.t('Local account expiration')"
                                         :text="$i18n.t('The amount of time after which the local account will expire. A value of 0 will use the access duration that is found via the authentication rules for the user.')"
    />

    <form-group-authentication-rules namespace="authentication_rules"
                                     :column-label="$i18n.t('Authentication Rules')"
    />
  </base-form>
</template>

<script>
import {BaseForm} from '@/components/new/'
import {
  FormGroupAuthenticationRules,
  FormGroupCreateLocalAccount,
  FormGroupDescription,
  FormGroupHashPasswords,
  FormGroupIdentifier,
  FormGroupLocalAccountExpiration,
  FormGroupLocalAccountLogins,
  FormGroupMessage,
  FormGroupPasswordLength,
  FormGroupPinCodeLength,
  FormGroupApiUrl,
  FormGroupServiceId, // <-- Added standard text group for our new fields
  FormGroupMessageId, // <-- Added standard text group for our new fields
  FormGroupInstitution, // <-- Added standard text group for our new fields
  FormGroupPresharedKey, // <-- Added standard text group for our new fields
} from './'

const components = {
  BaseForm,

  FormGroupAuthenticationRules,
  FormGroupCreateLocalAccount,
  FormGroupDescription,
  FormGroupHashPasswords,
  FormGroupIdentifier,
  FormGroupLocalAccountExpiration,
  FormGroupLocalAccountLogins,
  FormGroupMessage,
  FormGroupPasswordLength,
  FormGroupPinCodeLength,
  FormGroupApiUrl, // <-- Added to components list
  FormGroupServiceId, // <-- Added to components list
  FormGroupMessageId, // <-- Added to components list
  FormGroupInstitution, // <-- Added to components list
  FormGroupPresharedKey, // <-- Added to components list
}

import {useForm as setup, useFormProps as props} from '../_composables/useForm'

// @vue/component
export default {
  name: 'form-type-sms-gunet', // <-- Changed to match our new source
  inheritAttrs: false,
  components,
  props,
  setup
}
</script>
