<?php

namespace STS\Transformers;

use STS\User;
use League\Fractal\TransformerAbstract;

class ProfileTransformer extends TransformerAbstract
{
    protected $user;

    public function __construct($user)
    {
        $this->user = $user;
    }

    /**
     * Turn this item object into a generic array.
     *
     * @return array
     */
    public function transform(User $user)
    {
        $data = [
            'id' => $user->id,
            'name' => $user->name,
            // 'email' => $user->email,
            'description' => $user->description,
            'image' => $user->image,
            'positive_ratings' => $user->positive_ratings,
            'negative_ratings' => $user->negative_ratings,
            'birthday' => $user->birthday,
            'gender' => $user->gender,
            'mobile_phone' => $user->mobile_phone,
            'nro_doc' => $user->nro_doc,
            'last_connection' => $user->last_connection ? $user->last_connection->toDateTimeString() : '',
            'accounts' => $user->accounts,
            'donations' => $user->donations,
            'has_pin' => $user->has_pin,
            'is_member' => $user->is_member,
            'monthly_donate' => $user->monthly_donate,
            'do_not_alert_request_seat'       => $user->do_not_alert_request_seat,
            'do_not_alert_accept_passenger'   => $user->do_not_alert_accept_passenger,
            'do_not_alert_pending_rates'      => $user->do_not_alert_pending_rates
        ];
        if ($user->id = $this->user->id || $this->user->is_admin) {
            $data['emails_notifications'] = $user->emails_notifications;
            $data['is_admin'] = $user->is_admin;
            $data['accounts'] = $user->accounts;
            $data['donations'] = $user->donations;
            $data['email'] = $user->email;
        }

        if ($user->state) {
            $data['state'] = $user->state;
        }

        return $data;
    }
}
